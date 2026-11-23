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
