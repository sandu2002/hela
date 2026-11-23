const insforge = require('../config/insforge');
const db = require('../config/db');

/**
 * Auth Controller - Interfaces with InsForge BaaS Authentication
 */
exports.verifySession = async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (!token) {
      return res.status(401).json({ error: 'Authorization token required' });
    }

    const session = await insforge.fetchFromAuth('/sessions/current', {
      headers: { Authorization: `Bearer ${token}` },
    });

    res.json({ success: true, session });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const rows = await db.query('SELECT * FROM public.profiles WHERE auth_user_id = $1 OR id::text = $1', [userId]);

    if (!rows.length) {
      return res.status(404).json({ error: 'Profile not found' });
    }

    res.json({ success: true, profile: rows[0] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.syncProfile = async (req, res) => {
  try {
    const { authUserId, email, fullName, avatarUrl, bio } = req.body;
    const sql = `
      INSERT INTO public.profiles (auth_user_id, email, full_name, avatar_url, bio)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (auth_user_id) 
      DO UPDATE SET 
        full_name = EXCLUDED.full_name,
        avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url),
        bio = COALESCE(EXCLUDED.bio, profiles.bio),
        updated_at = NOW()
      RETURNING *;
    `;
    const rows = await db.query(sql, [authUserId, email, fullName, avatarUrl, bio]);
    res.json({ success: true, profile: rows[0] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
