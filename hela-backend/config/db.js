const insforge = require('./insforge');

/**
 * Database client helper for running queries against InsForge PostgreSQL
 */
async function query(sql, params = []) {
  try {
    const response = await fetch(`${insforge.baseUrl}/api/database/query`, {
      method: 'POST',
      headers: insforge.getHeaders(),
      body: JSON.stringify({ query: sql, params }),
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
