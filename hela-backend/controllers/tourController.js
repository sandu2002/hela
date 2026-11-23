const db = require('../config/db');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY || 'AQ.Ab8RN6LcBcIS8jiH2GzAdjwITZJtC1IXTrvgdQnvky5gXnv4CA';
const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash';

/**
 * Tour Controller - AI-Powered Itineraries & Tour Plans
 */
exports.generateTour = async (req, res) => {
  try {
    const { preferences, candidateDestinations } = req.body;
    const duration = preferences?.duration || 3;
    const startLoc = preferences?.startingLocationName || 'Colombo / Airport';
    const interests = (preferences?.interests || []).join(', ');
    const budget = preferences?.budgetLevel || 'medium';

    const prompt = `
You are a Sri Lanka travel expert AI for HELA.
Generate a ${duration}-day travel itinerary in JSON format starting from ${startLoc}.
Interests: ${interests}
Budget: ${budget}

Return ONLY valid JSON matching this structure:
{
  "title": "Itinerary Title",
  "summary": "Brief 2-3 sentence overview",
  "matchReason": "Why this matches preferences",
  "durationDays": ${duration},
  "estimatedTotalCostUsd": 250,
  "budgetBreakdown": "Breakdown of hotels, food, transport",
  "days": [
    {
      "dayNumber": 1,
      "title": "Day 1 Theme",
      "summary": "Day 1 summary",
      "activities": [
        {
          "title": "Activity name",
          "description": "Details",
          "startTime": "09:00 AM",
          "estimatedDuration": "2 hours",
          "category": "Culture",
          "estimatedCostUsd": 20
        }
      ]
    }
  ]
}
`;

    // Direct Gemini REST API Call
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
      }),
    });

    const data = await response.json();
    let text = data?.candidates?.[0]?.content?.parts?.[0]?.text || '{}';
    text = text.replace(/```json/g, '').replace(/```/g, '').trim();

    const plan = JSON.parse(text);
    res.json({ success: true, plan });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.saveTourPlan = async (req, res) => {
  try {
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

exports.getUserTourPlans = async (req, res) => {
  try {
    const { userId } = req.params;
    const plans = await db.query(
      'SELECT * FROM public.tour_plans WHERE user_id::text = $1 ORDER BY created_at DESC',
      [userId]
    );
    res.json({ success: true, count: plans.length, plans });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
