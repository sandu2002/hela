const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';
const GEMINI_MODEL   = process.env.GEMINI_MODEL   || 'gemini-2.0-flash';
const GEMINI_FALLBACK      = 'gemini-1.5-flash';
const GEMINI_LITE_FALLBACK = 'gemini-1.5-flash-8b';

const GEMINI_BASE = 'https://generativelanguage.googleapis.com/v1beta/models';

/**
 * Calls Gemini with a 3-tier model fallback.
 * Returns { text, modelName } or throws.
 */
async function geminiGenerate(prompt, { responseMimeType = 'application/json' } = {}) {
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
      if (text) return { text, modelName: model };
    } catch (e) {
      lastErr = e;
      console.warn(`[AI] ${model} failed: ${e.message}`);
    }
  }
  throw new Error(`All Gemini models failed: ${lastErr?.message}`);
}

/**
 * POST /api/tours/generate
 * Body: { prompt: string, expectArray?: boolean }
 * Returns: { success: true, text: string, modelName: string }
 */
exports.generateTour = async (req, res) => {
  try {
    if (!GEMINI_API_KEY) {
      return res.status(503).json({ error: 'AI service not configured on server.' });
    }
    const { prompt, responseMimeType } = req.body;
    if (!prompt || typeof prompt !== 'string' || prompt.trim().length < 10) {
      return res.status(400).json({ error: 'Missing or invalid prompt.' });
    }
    // Basic abuse guard: reject suspiciously short or oversized prompts
    if (prompt.length > 32_000) {
      return res.status(400).json({ error: 'Prompt too large.' });
    }

    const mimeType = responseMimeType === 'text/plain' ? 'text/plain' : 'application/json';
    const { text, modelName } = await geminiGenerate(prompt, { responseMimeType: mimeType });
    res.json({ success: true, text, modelName });
  } catch (error) {
    console.error('[tourController] generateTour error:', error.message);
    res.status(500).json({ error: error.message });
  }
};

/**
 * POST /api/tours/save
 */
exports.saveTourPlan = async (req, res) => {
  try {
    const db = require('../config/db');
    const { userId, plan } = req.body;
    const sql = `
      INSERT INTO public.tour_plans (
        user_id, title, summary, match_reason, duration_days,
        estimated_total_cost_usd, budget_breakdown, days_data, is_saved
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true)
      RETURNING *;
    `;
    const rows = await db.query(sql, [
      userId,
      plan.title,
      plan.summary,
      plan.matchReason,
      plan.durationDays,
      plan.estimatedTotalCostUsd,
      plan.budgetBreakdown,
      JSON.stringify(plan.days || []),
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
    const plans = await db.query(
      'SELECT * FROM public.tour_plans WHERE user_id::text = $1 ORDER BY created_at DESC',
      [userId],
    );
    res.json({ success: true, count: plans.length, plans });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
