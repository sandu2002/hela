const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const insforge = require('../config/insforge');
const db = require('../config/db');
const { createRateLimiter } = require('../middleware/rateLimit');
const app = require('../server');

async function withServer(fn) {
  const server = app.listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  const { port } = server.address();
  const baseUrl = `http://127.0.0.1:${port}`;
  try {
    await fn(baseUrl);
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

test('Protected endpoints reject unauthenticated requests with 401', async () => {
  await withServer(async (baseUrl) => {
    const routes = [
      { method: 'GET', path: '/api/auth/session' },
      { method: 'GET', path: '/api/auth/profile/user-a' },
      { method: 'POST', path: '/api/auth/profile/sync', body: { fullName: 'Alice', email: 'a@example.com' } },
      { method: 'POST', path: '/api/tours/save', body: { userId: 'user-a', plan: { title: 'Test', durationDays: 3 } } },
      { method: 'GET', path: '/api/tours/user/user-a' },
      { method: 'GET', path: '/api/rides/history/user-a' },
    ];

    for (const r of routes) {
      const res = await fetch(`${baseUrl}${r.path}`, {
        method: r.method,
        headers: { 'Content-Type': 'application/json' },
        body: r.body ? JSON.stringify(r.body) : undefined,
      });
      assert.equal(res.status, 401, `${r.method} ${r.path} must require authentication`);
    }
  });
});

test('Authorization blocks cross-user IDOR and allows resource owner', async () => {
  const origFetchAuth = insforge.fetchFromAuth;
  const origQuery = db.query;

  insforge.fetchFromAuth = async (_endpoint, opts = {}) => {
    const authHeader = opts.headers?.Authorization || '';
    if (authHeader === 'Bearer token-alice') {
      return { user: { id: 'alice-auth-id', email: 'alice@example.com' } };
    }
    const err = new Error('Invalid token');
    err.statusCode = 401;
    throw err;
  };

  db.query = async (sql, params) => {
    if (sql.includes('FROM public.profiles')) {
      if (params[0] === 'alice-auth-id') {
        return [{ id: 'profile-alice', auth_user_id: 'alice-auth-id', email: 'alice@example.com', full_name: 'Alice' }];
      }
      if (params[0] === 'bob-auth-id' || params[0] === 'profile-bob') {
        return [{ id: 'profile-bob', auth_user_id: 'bob-auth-id', email: 'bob@example.com', full_name: 'Bob' }];
      }
      return [];
    }
    if (sql.includes('FROM public.tour_plans')) {
      return [{ id: 'tour-1', user_id: params[0], title: 'Ella Escape' }];
    }
    if (sql.includes('FROM public.fair_rides')) {
      return [{ id: 'ride-1', user_id: params[0], estimated_fare_lkr: 1020 }];
    }
    return [];
  };

  try {
    await withServer(async (baseUrl) => {
      // Cross-user reads & writes rejected with 403
      const otherProfile = await fetch(`${baseUrl}/api/auth/profile/bob-auth-id`, {
        headers: { Authorization: 'Bearer token-alice' },
      });
      assert.equal(otherProfile.status, 403);

      const otherSync = await fetch(`${baseUrl}/api/auth/profile/sync`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer token-alice',
        },
        body: JSON.stringify({
          authUserId: 'bob-auth-id',
          email: 'alice@example.com',
          fullName: 'Alice',
        }),
      });
      assert.equal(otherSync.status, 403);

      const otherTours = await fetch(`${baseUrl}/api/tours/user/bob-auth-id`, {
        headers: { Authorization: 'Bearer token-alice' },
      });
      assert.equal(otherTours.status, 403);

      const otherRides = await fetch(`${baseUrl}/api/rides/history/bob-auth-id`, {
        headers: { Authorization: 'Bearer token-alice' },
      });
      assert.equal(otherRides.status, 403);

      // Owner access succeeds with 200
      const ownProfile = await fetch(`${baseUrl}/api/auth/profile/alice-auth-id`, {
        headers: { Authorization: 'Bearer token-alice' },
      });
      assert.equal(ownProfile.status, 200);
      const ownProfileData = await ownProfile.json();
      assert.equal(ownProfileData.profile.auth_user_id, 'alice-auth-id');

      const ownTours = await fetch(`${baseUrl}/api/tours/user/alice-auth-id`, {
        headers: { Authorization: 'Bearer token-alice' },
      });
      assert.equal(ownTours.status, 200);

      const ownRides = await fetch(`${baseUrl}/api/rides/history/alice-auth-id`, {
        headers: { Authorization: 'Bearer token-alice' },
      });
      assert.equal(ownRides.status, 200);
    });
  } finally {
    insforge.fetchFromAuth = origFetchAuth;
    db.query = origQuery;
  }
});

test('Input validation rejects invalid fare/profile payloads and insforge has no hardcoded private API key', async () => {
  // Verify private INSFORGE_API_KEY is never hardcoded in source
  const insforgeSource = fs.readFileSync(path.join(__dirname, '../config/insforge.js'), 'utf8');
  assert.ok(!/['"]ik_[A-Za-z0-9]{10,}['"]/.test(insforgeSource), 'Private server key must not be hardcoded');

  await withServer(async (baseUrl) => {
    const badDist = await fetch(`${baseUrl}/api/rides/calculate-fare`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vehicleType: 'Tuk-Tuk', distanceKm: -10 }),
    });
    assert.equal(badDist.status, 400);

    const badVehicle = await fetch(`${baseUrl}/api/rides/calculate-fare`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vehicleType: 'Helicopter', distanceKm: 12 }),
    });
    assert.equal(badVehicle.status, 400);

    const okFare = await fetch(`${baseUrl}/api/rides/calculate-fare`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ vehicleType: 'Tuk-Tuk', distanceKm: 10, quotedFareLkr: 1050 }),
    });
    assert.equal(okFare.status, 200);
    const fareData = await okFare.json();
    assert.equal(fareData.estimatedFareLkr, 1020);
    assert.equal(fareData.isFair, true);
  });
});

test('Rate limiter blocks excessive requests with 429', () => {
  const limiter = createRateLimiter({ windowMs: 60_000, max: 2 });
  const headers = {};
  const makeRes = () => ({
    statusCode: 200,
    setHeader(k, v) { headers[k] = v; },
    status(code) {
      this.statusCode = code;
      return { json: (body) => ({ code, body }) };
    },
  });
  const req = { ip: '203.0.113.10' };

  let nextCalls = 0;
  limiter(req, makeRes(), () => { nextCalls += 1; });
  limiter(req, makeRes(), () => { nextCalls += 1; });
  assert.equal(nextCalls, 2);

  const blockedRes = makeRes();
  const out = limiter(req, blockedRes, () => { nextCalls += 1; });
  assert.equal(nextCalls, 2);
  assert.equal(out.code, 429);
  assert.ok(headers['Retry-After']);
});
