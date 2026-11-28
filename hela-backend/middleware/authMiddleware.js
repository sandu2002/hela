const insforge = require('../config/insforge');
const db = require('../config/db');

function extractBearerToken(req) {
  const header = req.headers?.authorization;
  if (typeof header !== 'string') return '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match ? match[1].trim() : '';
}

function normalizeSessionUser(session) {
  if (!session || typeof session !== 'object') return null;
  const userObj = session.user && typeof session.user === 'object' ? session.user : session;
  const id = userObj.id || userObj.userId || userObj.sub;
  if (!id || typeof id !== 'string' || !id.trim()) return null;
  return {
    id: id.trim(),
    email: typeof userObj.email === 'string' ? userObj.email.trim() : '',
    raw: session,
  };
}

/**
 * Resolves the authenticated InsForge user from a Bearer token.
 * Throws `{ statusCode: 401 }` when token verification fails.
 */
async function verifyBearerToken(token) {
  if (!token) {
    const err = new Error('Authorization token required');
    err.statusCode = 401;
    throw err;
  }
  const session = await insforge.fetchFromAuth('/sessions/current', {
    headers: { Authorization: `Bearer ${token}` },
  });
  const user = normalizeSessionUser(session);
  if (!user) {
    const err = new Error('Invalid or expired session');
    err.statusCode = 401;
    throw err;
  }
  return user;
}

function createAuthMiddleware({ verifier = verifyBearerToken } = {}) {
  async function requireAuth(req, res, next) {
    const token = extractBearerToken(req);
    if (!token) {
      return res.status(401).json({ error: 'Authorization token required' });
    }
    try {
      req.authUser = await verifier(token);
      return next();
    } catch (err) {
      const status = err?.statusCode === 401 || err?.statusCode === 403 ? err.statusCode : 401;
      return res.status(status).json({ error: 'Invalid or expired authorization token' });
    }
  }

  async function optionalAuth(req, res, next) {
    const token = extractBearerToken(req);
    if (!token) {
      req.authUser = null;
      return next();
    }
    try {
      req.authUser = await verifier(token);
      return next();
    } catch (_) {
      return res.status(401).json({ error: 'Invalid or expired authorization token' });
    }
  }

  return { requireAuth, optionalAuth };
}

/**
 * Verifies whether [authUser] owns the requested [userId] (matching either auth_user_id or profile UUID).
 */
async function userOwnsIdentifier(authUser, requestedUserId, queryFn = db.query) {
  if (!authUser || !authUser.id || !requestedUserId) return false;
  const target = String(requestedUserId).trim();
  if (!target) return false;
  if (authUser.id === target) return true;

  const rows = await queryFn(
    'SELECT id, auth_user_id FROM public.profiles WHERE (id::text = $1 OR auth_user_id = $1) LIMIT 1',
    [target],
  );
  if (!rows.length) return false;
  const row = rows[0];
  return row.auth_user_id === authUser.id;
}

const { requireAuth, optionalAuth } = createAuthMiddleware();

module.exports = {
  extractBearerToken,
  normalizeSessionUser,
  verifyBearerToken,
  createAuthMiddleware,
  userOwnsIdentifier,
  requireAuth,
  optionalAuth,
};
