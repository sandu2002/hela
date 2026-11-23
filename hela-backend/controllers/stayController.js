const db = require('../config/db');

/**
 * Stays Controller - Accommodations, Eco Lodges & Havens
 */
exports.getAllStays = async (req, res) => {
  try {
    const { category, location } = req.query;
    let queryStr = 'SELECT * FROM public.haven_stays WHERE 1=1';
    const params = [];

    if (category) {
      params.push(category);
      queryStr += ` AND (category ILIKE $${params.length} OR filter_category ILIKE $${params.length})`;
    }

    if (location) {
      params.push(`%${location}%`);
      queryStr += ` AND location ILIKE $${params.length}`;
    }

    queryStr += ' ORDER BY rating DESC';
    const stays = await db.query(queryStr, params);
    res.json({ success: true, count: stays.length, stays });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
