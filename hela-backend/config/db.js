const insforge = require('./insforge');

/**
 * Database client helper for running queries against InsForge PostgreSQL
 */
async function query(sql, params = []) {
  if (!insforge.apiKey && !insforge.anonKey) {
    throw new Error('Server database credentials are not configured.');
  }
  try {
    const response = await fetch(`${insforge.baseUrl}/api/database/query`, {
      method: 'POST',
      headers: insforge.getHeaders(),
      body: JSON.stringify({ query: sql, params }),
      signal: AbortSignal.timeout(15_000),
    });

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`Database Query Failed (${response.status}): ${errText}`);
    }

    const data = await response.json();
    return data.rows || [];
  } catch (err) {
    console.error('DB query error:', err.message);
    throw err;
  }
}

module.exports = {
  query,
};
