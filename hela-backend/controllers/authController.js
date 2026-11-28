const insforge = require('../config/insforge');
const db = require('../config/db');
const { extractBearerToken, userOwnsIdentifier } = require('../middleware/authMiddleware');

function isValidHttpUrl(value) {
  if (!value) return true;
  try {
    const parsed = new URL(String(value));
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch (_) {
    return false;
  }
}

/**
 * Auth Controller - Interfaces with InsForge BaaS Authentication
 */
exports.verifySession = async (req, res) => {
  try {
    const token = extractBearerToken(req);
    if (!token) {
      return res.status(401).json({ error: 'Authorization token required' });
    }

    const session = await insforge.fetchFromAuth('/sessions/current', {
      headers: { Authorization: `Bearer ${token}` },
    });

    res.json({ success: true, session });
  } catch (error) {
    const status = error?.statusCode === 401 || error?.statusCode === 403 ? error.statusCode : 401;
    res.status(status).json({ error: error.message || 'Invalid session' });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const targetId = typeof userId === 'string' ? userId.trim() : '';
    if (!targetId || targetId.length > 128) {
      return res.status(400).json({ error: 'Invalid user identifier' });
    }

    const authorized = await userOwnsIdentifier(req.authUser, targetId);
    if (!authorized) {
      return res.status(403).json({ error: 'Forbidden: cannot access another user profile' });
    }

    const rows = await db.query(
      'SELECT id, auth_user_id, email, full_name, avatar_url, bio, phone_number, country, travel_preferences, is_verified, created_at, updated_at FROM public.profiles WHERE auth_user_id = $1 OR id::text = $1 LIMIT 1',
      [targetId],
    );

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
    const { authUserId, email, fullName, avatarUrl, bio } = req.body || {};
    const callerId = req.authUser?.id;
    if (!callerId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    if (authUserId && String(authUserId).trim() !== callerId) {
      return res.status(403).json({ error: 'Forbidden: cannot modify another user profile' });
    }

    const cleanEmail = typeof email === 'string' && email.trim() ? email.trim() : req.authUser.email;
    if (!cleanEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail) || cleanEmail.length > 255) {
      return res.status(400).json({ error: 'Valid email is required' });
    }

    const cleanName = typeof fullName === 'string' ? fullName.trim() : '';
    if (!cleanName || cleanName.length > 120) {
      return res.status(400).json({ error: 'Full name is required (max 120 chars)' });
    }

    const cleanAvatar = typeof avatarUrl === 'string' && avatarUrl.trim() ? avatarUrl.trim() : null;
    if (cleanAvatar && (cleanAvatar.length > 1000 || !isValidHttpUrl(cleanAvatar))) {
      return res.status(400).json({ error: 'Invalid avatar URL' });
    }

    const cleanBio = typeof bio === 'string' ? bio.trim().slice(0, 500) : null;

    const sql = `
      INSERT INTO public.profiles (auth_user_id, email, full_name, avatar_url, bio)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (auth_user_id) 
      DO UPDATE SET 
        full_name = EXCLUDED.full_name,
        avatar_url = COALESCE(EXCLUDED.avatar_url, profiles.avatar_url),
        bio = COALESCE(EXCLUDED.bio, profiles.bio),
        updated_at = NOW()
      RETURNING id, auth_user_id, email, full_name, avatar_url, bio, country, is_verified, created_at, updated_at;
    `;
    const rows = await db.query(sql, [callerId, cleanEmail, cleanName, cleanAvatar, cleanBio]);
    res.json({ success: true, profile: rows[0] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
