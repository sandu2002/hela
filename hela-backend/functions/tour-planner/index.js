/**
 * InsForge Edge Function: Tour Planner
 * Serverless Deno / Node Edge Function for AI Tour Plan Generation
 */
module.exports = async function(request) {
  try {
    const { method } = request;
    if (method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method Not Allowed' }), {
        status: 405,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const body = await request.json();
    const { preferences } = body;
    const duration = preferences?.duration || 3;
    const apiKey =
      (typeof process !== 'undefined' && process.env && process.env.GEMINI_API_KEY) ||
      (typeof Deno !== 'undefined' && Deno.env && Deno.env.get('GEMINI_API_KEY')) ||
      '';
    if (!apiKey) {
      return new Response(JSON.stringify({ error: 'AI service not configured' }), {
        status: 503,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    const prompt = `You are a Sri Lanka travel assistant. Generate a ${duration}-day itinerary for interests: ${(preferences?.interests || []).join(', ')}. Return JSON only.`;

    const geminiRes = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
        }),
      }
    );

    const data = await geminiRes.json();
    return new Response(JSON.stringify({ success: true, data }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
};
