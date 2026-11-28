const db = require('../config/db');

/**
 * Destinations Controller - Sri Lanka Attractions & Heritage Sites
 */
exports.getAllDestinations = async (req, res) => {
  try {
    const { region, category, search } = req.query;
    let queryStr = 'SELECT * FROM public.destinations WHERE 1=1';
    const params = [];

    if (region) {
      params.push(`%${region}%`);
      queryStr += ` AND region ILIKE $${params.length}`;
    }

    if (category) {
      params.push(category);
      queryStr += ` AND $${params.length} = ANY(categories)`;
    }

    if (search) {
      params.push(`%${search}%`);
      queryStr += ` AND (name ILIKE $${params.length} OR description ILIKE $${params.length})`;
    }

    queryStr += ' ORDER BY relevance_score DESC, rating DESC';

    const destinations = await db.query(queryStr, params);
    res.json({ success: true, count: destinations.length, destinations });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getDestinationById = async (req, res) => {
  try {
    const { id } = req.params;
    const rows = await db.query('SELECT * FROM public.destinations WHERE id::text = $1 OR source_id = $1', [id]);

    if (!rows.length) {
      return res.status(404).json({ error: 'Destination not found' });
    }

    res.json({ success: true, destination: rows[0] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const liveRatingCache = new Map();
const LIVE_RATING_TTL_MS = 60 * 60 * 1000;
const LIVE_RATING_MAX_CACHE = 500;

function formatCompactCount(count) {
  if (!Number.isFinite(count) || count <= 0) return null;
  if (count >= 1_000_000) return `${(count / 1_000_000).toFixed(1).replace(/\.0$/, '')}M`;
  if (count >= 1_000) return `${(count / 1_000).toFixed(1).replace(/\.0$/, '')}k`;
  return String(Math.round(count));
}

exports.getLiveDestinationRating = async (req, res) => {
  try {
    const { name, region, latitude, longitude } = req.body || {};
    if (!name || typeof name !== 'string' || !name.trim() || name.trim().length > 140) {
      return res.status(400).json({ error: 'Missing or invalid destination name.' });
    }

    const cleanName = name.trim();
    const cacheKey = `${cleanName.toLowerCase()}|${(typeof region === 'string' ? region : '').trim().toLowerCase()}`;
    const cached = liveRatingCache.get(cacheKey);
    if (cached && Date.now() - cached.cachedAt < LIVE_RATING_TTL_MS) {
      return res.json({ success: true, ...cached.data, cached: true });
    }

    const textQuery = cleanName.toLowerCase().includes('sri lanka')
      ? cleanName
      : `${cleanName}${region ? `, ${String(region).replace(/•/g, ' ')}` : ''}, Sri Lanka`;

    let result = null;
    const placesKey = (process.env.GOOGLE_PLACES_API_KEY || '').trim();
    if (placesKey) {
      try {
        const body = { textQuery, maxResultCount: 1, languageCode: 'en' };
        if (Number.isFinite(Number(latitude)) && Number.isFinite(Number(longitude))) {
          body.locationBias = {
            circle: {
              center: { latitude: Number(latitude), longitude: Number(longitude) },
              radius: 15000,
            },
          };
        }
        const pRes = await fetch('https://places.googleapis.com/v1/places:searchText', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': placesKey,
            'X-Goog-FieldMask':
              'places.displayName,places.rating,places.userRatingCount,places.googleMapsUri,places.currentOpeningHours.openNow',
          },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(8000),
        });
        if (pRes.ok) {
          const pData = await pRes.json();
          const place = pData?.places?.[0];
          if (place && typeof place.rating === 'number') {
            result = {
              name: place.displayName?.text || cleanName,
              rating: Number(place.rating.toFixed(1)),
              userRatingCount: place.userRatingCount || null,
              reviewCount: formatCompactCount(place.userRatingCount),
              openNow: place.currentOpeningHours?.openNow ?? null,
              googleMapsUri: place.googleMapsUri || null,
              source: 'Google Places',
            };
          }
        }
      } catch (e) {
        console.warn('[destinationController] Google Places lookup error:', e.message);
      }
    }

    const geminiKey = (process.env.GEMINI_API_KEY || '').trim();
    if (!result && geminiKey) {
      try {
        const gModel = process.env.GEMINI_MODEL || 'gemini-3.5-flash-lite';
        const gRes = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/${gModel}:generateContent?key=${geminiKey}`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{
                parts: [{
                  text: `Search Google for the live Google Maps star rating (1.0-5.0, 1 decimal) and total Google review count for "${textQuery}". Reply ONLY with JSON: {"rating": 4.5, "reviewCount": "11.2k", "openNow": true}`,
                }],
              }],
              tools: [{ google_search: {} }],
            }),
            signal: AbortSignal.timeout(10000),
          },
        );
        if (gRes.ok) {
          const gData = await gRes.json();
          const text = gData?.candidates?.[0]?.content?.parts?.map((p) => p.text || '').join(' ') || '';
          const match = text.match(/\{[\s\S]*\}/);
          if (match) {
            const parsed = JSON.parse(match[0]);
            if (typeof parsed.rating === 'number' && parsed.rating >= 1 && parsed.rating <= 5) {
              result = {
                name: cleanName,
                rating: Number(parsed.rating.toFixed(1)),
                reviewCount: parsed.reviewCount ? String(parsed.reviewCount) : null,
                openNow: typeof parsed.openNow === 'boolean' ? parsed.openNow : null,
                source: 'Google Search',
              };
            }
          }
        }
      } catch (e) {
        console.warn('[destinationController] Gemini Search grounding error:', e.message);
      }
    }

    if (!result) {
      return res.status(404).json({ error: 'Live Google rating temporarily unavailable.' });
    }

    if (liveRatingCache.size >= LIVE_RATING_MAX_CACHE) {
      const oldestKey = liveRatingCache.keys().next().value;
      if (oldestKey !== undefined) liveRatingCache.delete(oldestKey);
    }
    liveRatingCache.set(cacheKey, { data: result, cachedAt: Date.now() });
    res.json({ success: true, ...result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
