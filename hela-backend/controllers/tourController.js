const { userOwnsIdentifier } = require('../middleware/authMiddleware');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const GEMINI_MODEL   = process.env.GEMINI_MODEL   || 'gemini-3.5-flash-lite';
const GEMINI_FALLBACK      = 'gemini-3.1-flash-lite';
const GEMINI_LITE_FALLBACK = 'gemini-2.5-flash';

const GEMINI_BASE = 'https://generativelanguage.googleapis.com/v1beta/models';

const DEEPSEEK_API_KEY        = (process.env.DEEPSEEK_API_KEY || process.env.OPENROUTER_API_KEY || '').trim();
const DEEPSEEK_BASE_URL       = (process.env.DEEPSEEK_BASE_URL || '').trim().replace(/\/+$/, '');
const DEEPSEEK_MODEL          = (process.env.DEEPSEEK_MODEL || '').trim();
const DEEPSEEK_FALLBACK_MODEL = (process.env.DEEPSEEK_FALLBACK_MODEL || 'openrouter/free').trim();

/**
 * Resolves OpenAI-compatible DeepSeek endpoint and candidate models from env vars.
 * Returns null if neither an API key nor a local custom base URL is configured.
 */
function resolveDeepseekConfig() {
  const isLocalEndpoint = /^https?:\/\/(localhost|127\.0\.0\.1|10\.0\.2\.2)(:\d+)?/i.test(DEEPSEEK_BASE_URL);
  if (!DEEPSEEK_API_KEY && !isLocalEndpoint) {
    return null;
  }

  let baseUrl = DEEPSEEK_BASE_URL;
  let defaultModels;

  if (DEEPSEEK_API_KEY.startsWith('sk-or-')) {
    if (!baseUrl) baseUrl = 'https://openrouter.ai/api/v1';
    defaultModels = ['deepseek/deepseek-v4.1-flash', 'deepseek/deepseek-chat', DEEPSEEK_FALLBACK_MODEL];
  } else if (DEEPSEEK_API_KEY.startsWith('nvapi-')) {
    if (!baseUrl) baseUrl = 'https://integrate.api.nvidia.com/v1';
    defaultModels = ['deepseek-ai/deepseek-v3.2', 'deepseek-ai/deepseek-r1'];
  } else if (isLocalEndpoint) {
    defaultModels = ['deepseek-r1', 'deepseek-chat'];
  } else {
    if (!baseUrl) baseUrl = 'https://api.deepseek.com/v1';
    defaultModels = ['deepseek-chat', 'deepseek-reasoner'];
  }

  const candidateModels = [...new Set([DEEPSEEK_MODEL, ...defaultModels].filter(Boolean))];
  return { baseUrl, apiKey: DEEPSEEK_API_KEY, candidateModels };
}

/**
 * Strips `<think>...</think>` reasoning blocks emitted by reasoning models like DeepSeek-R1.
 */
function stripReasoningTags(text) {
  return String(text || '').replace(/<think>[\s\S]*?<\/think>/gi, '').trim();
}

/**
 * Calls an OpenAI-compatible `/chat/completions` endpoint for DeepSeek / OpenRouter / NVIDIA NIM.
 * Returns { text, modelName, provider } or throws.
 */
async function deepseekChatGenerate(messages, { responseMimeType = 'text/plain', expectArray = false } = {}) {
  const config = resolveDeepseekConfig();
  if (!config) {
    throw new Error('DeepSeek / OpenAI-compatible API key is not configured on server.');
  }

  const { baseUrl, apiKey, candidateModels } = config;
  const endpoint = `${baseUrl}/chat/completions`;
  const headers = { 'Content-Type': 'application/json' };
  if (apiKey) {
    headers.Authorization = `Bearer ${apiKey}`;
  }
  if (baseUrl.includes('openrouter.ai')) {
    headers['HTTP-Referer'] = 'https://hela.travel';
    headers['X-Title'] = 'HELA Sri Lanka Travel Companion';
  }

  let lastErr;
  for (const model of candidateModels) {
    try {
      const payload = {
        model,
        messages,
        temperature: responseMimeType === 'application/json' ? 0.5 : 0.7,
      };
      const supportsJsonObject =
        responseMimeType === 'application/json' &&
        !expectArray &&
        !baseUrl.includes('integrate.api.nvidia.com') &&
        !model.includes('v4') &&
        !model.includes('free');
      if (supportsJsonObject) {
        payload.response_format = { type: 'json_object' };
      }

      const res = await fetch(endpoint, {
        method: 'POST',
        headers,
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(60_000),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error?.message || `HTTP ${res.status}`);

      const rawText = data?.choices?.[0]?.message?.content;
      const text = stripReasoningTags(rawText);
      if (text) return { text, modelName: model, provider: 'deepseek' };
    } catch (e) {
      lastErr = e;
      console.warn(`[DeepSeek AI] ${model} failed: ${e.message}`);
    }
  }
  throw new Error(`All DeepSeek models failed: ${lastErr?.message}`);
}

/**
 * Calls Gemini with a 3-tier model fallback.
 * Returns { text, modelName, provider } or throws.
 */
async function geminiGenerate(prompt, { responseMimeType = 'application/json' } = {}) {
  if (!GEMINI_API_KEY) {
    throw new Error('Gemini API key not configured on server.');
  }
  const models = [GEMINI_MODEL, GEMINI_FALLBACK, GEMINI_LITE_FALLBACK];
  let lastErr;
  for (const model of models) {
    try {
      const url = `${GEMINI_BASE}/${model}:generateContent?key=${GEMINI_API_KEY}`;
      const body = {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { responseMimeType },
      };
      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(60_000),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error?.message || `HTTP ${res.status}`);
      const text = data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
      if (text) return { text, modelName: model, provider: 'gemini' };
    } catch (e) {
      lastErr = e;
      console.warn(`[AI] ${model} failed: ${e.message}`);
    }
  }
  throw new Error(`All Gemini models failed: ${lastErr?.message}`);
}

/**
 * POST /api/tours/generate
 * Body: { prompt: string, responseMimeType?: string, preferredProvider?: 'gemini' | 'deepseek' }
 * Returns: { success: true, text: string, modelName: string, provider: string }
 */
exports.generateTour = async (req, res) => {
  try {
    const { prompt, responseMimeType, preferredProvider, expectArray } = req.body;
    if (!prompt || typeof prompt !== 'string' || prompt.trim().length < 10) {
      return res.status(400).json({ error: 'Missing or invalid prompt.' });
    }
    // Basic abuse guard: reject suspiciously short or oversized prompts
    if (prompt.length > 32_000) {
      return res.status(400).json({ error: 'Prompt too large.' });
    }

    const mimeType = responseMimeType === 'text/plain' ? 'text/plain' : 'application/json';

    if (preferredProvider === 'deepseek' && resolveDeepseekConfig()) {
      try {
        const result = await deepseekChatGenerate(
          [{ role: 'user', content: prompt }],
          { responseMimeType: mimeType, expectArray: Boolean(expectArray) },
        );
        return res.json({ success: true, ...result });
      } catch (e) {
        console.warn('[tourController] DeepSeek primary failed, falling back to Gemini:', e.message);
      }
    }

    if (!GEMINI_API_KEY) {
      return res.status(503).json({ error: 'AI service not configured on server.' });
    }
    const result = await geminiGenerate(prompt, { responseMimeType: mimeType });
    res.json({ success: true, ...result });
  } catch (error) {
    console.error('[tourController] generateTour error:', error.message);
    res.status(500).json({ error: error.message });
  }
};

/**
 * POST /api/tours/chat
 * Ask HELA endpoint: uses DeepSeek (OpenAI-compatible) as primary and falls back to Gemini.
 * Body: { prompt: string, systemInstruction?: string, history?: Array<{ isUser: boolean, text: string }> }
 */
exports.chatAskHela = async (req, res) => {
  try {
    const { prompt, systemInstruction = '', history = [] } = req.body;
    if (!prompt || typeof prompt !== 'string' || prompt.trim().length === 0) {
      return res.status(400).json({ error: 'Missing or invalid prompt.' });
    }
    if (prompt.length > 32_000) {
      return res.status(400).json({ error: 'Prompt too large.' });
    }

    const safeHistory = Array.isArray(history) ? history.slice(-10) : [];
    const messages = [];
    if (systemInstruction && typeof systemInstruction === 'string' && systemInstruction.trim()) {
      messages.push({ role: 'system', content: systemInstruction.trim() });
    }
    for (const turn of safeHistory) {
      if (turn && typeof turn.text === 'string' && turn.text.trim()) {
        messages.push({ role: turn.isUser ? 'user' : 'assistant', content: turn.text });
      }
    }
    messages.push({ role: 'user', content: prompt.trim() });

    if (resolveDeepseekConfig()) {
      try {
        const result = await deepseekChatGenerate(messages, { responseMimeType: 'text/plain' });
        return res.json({ success: true, ...result });
      } catch (deepErr) {
        console.warn('[tourController] Ask HELA DeepSeek primary failed, falling back to Gemini:', deepErr.message);
      }
    }

    if (GEMINI_API_KEY) {
      const historyStr = safeHistory
        .filter((t) => t && typeof t.text === 'string' && t.text.trim())
        .map((t) => `${t.isUser ? 'Traveler' : 'HELA'}: ${t.text}`)
        .join('\n');
      const fullPrompt = `${systemInstruction}\n\n${historyStr ? `Conversation history:\n${historyStr}\n\n` : ''}Traveler: ${prompt}\nHELA:`;
      const result = await geminiGenerate(fullPrompt, { responseMimeType: 'text/plain' });
      return res.json({ success: true, ...result });
    }

    return res.status(503).json({ error: 'No AI provider configured on server.' });
  } catch (error) {
    console.error('[tourController] chatAskHela error:', error.message);
    res.status(500).json({ error: error.message });
  }
};

/**
 * POST /api/tours/save
 */
exports.saveTourPlan = async (req, res) => {
  try {
    const db = require('../config/db');
    const { userId, plan } = req.body || {};
    const targetUserId = typeof userId === 'string' ? userId.trim() : '';
    if (!targetUserId || targetUserId.length > 128) {
      return res.status(400).json({ error: 'Valid userId is required.' });
    }
    const authorized = await userOwnsIdentifier(req.authUser, targetUserId);
    if (!authorized) {
      return res.status(403).json({ error: 'Forbidden: cannot save tour plan for another user.' });
    }

    if (!plan || typeof plan !== 'object') {
      return res.status(400).json({ error: 'Tour plan payload is required.' });
    }
    const title = typeof plan.title === 'string' ? plan.title.trim() : '';
    if (!title || title.length > 180) {
      return res.status(400).json({ error: 'Valid plan title is required (max 180 chars).' });
    }
    const durationDays = Number(plan.durationDays || 1);
    if (!Number.isInteger(durationDays) || durationDays < 1 || durationDays > 30) {
      return res.status(400).json({ error: 'durationDays must be an integer between 1 and 30.' });
    }
    const estimatedTotalCostUsd = plan.estimatedTotalCostUsd != null
      ? Number(plan.estimatedTotalCostUsd)
      : null;
    if (estimatedTotalCostUsd !== null && (!Number.isFinite(estimatedTotalCostUsd) || estimatedTotalCostUsd < 0)) {
      return res.status(400).json({ error: 'estimatedTotalCostUsd must be a non-negative finite number.' });
    }
    const days = Array.isArray(plan.days) ? plan.days.slice(0, 30) : [];

    const sql = `
      INSERT INTO public.tour_plans (
        user_id, title, summary, match_reason, duration_days,
        estimated_total_cost_usd, budget_breakdown, days_data, is_saved
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true)
      RETURNING *;
    `;
    const rows = await db.query(sql, [
      targetUserId,
      title,
      typeof plan.summary === 'string' ? plan.summary.slice(0, 1000) : '',
      typeof plan.matchReason === 'string' ? plan.matchReason.slice(0, 500) : '',
      durationDays,
      estimatedTotalCostUsd,
      typeof plan.budgetBreakdown === 'string' ? plan.budgetBreakdown.slice(0, 1000) : '',
      JSON.stringify(days),
    ]);
    res.json({ success: true, tourPlan: rows[0] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

/**
 * GET /api/tours/user/:userId
 */
exports.getUserTourPlans = async (req, res) => {
  try {
    const db = require('../config/db');
    const { userId } = req.params;
    const targetUserId = typeof userId === 'string' ? userId.trim() : '';
    if (!targetUserId || targetUserId.length > 128) {
      return res.status(400).json({ error: 'Invalid user identifier.' });
    }
    const authorized = await userOwnsIdentifier(req.authUser, targetUserId);
    if (!authorized) {
      return res.status(403).json({ error: 'Forbidden: cannot access another user tour plans.' });
    }

    const plans = await db.query(
      'SELECT * FROM public.tour_plans WHERE user_id::text = $1 ORDER BY created_at DESC LIMIT 50',
      [targetUserId],
    );
    res.json({ success: true, count: plans.length, plans });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
