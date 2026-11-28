require('dotenv').config();

const INSFORGE_BASE_URL = (process.env.INSFORGE_BASE_URL || 'https://tvf24g8r.us-east.insforge.app').trim().replace(/\/+$/, '');
const INSFORGE_API_KEY = (process.env.INSFORGE_API_KEY || '').trim();
const INSFORGE_ANON_KEY = (process.env.INSFORGE_ANON_KEY || '').trim();

/**
 * InsForge BaaS REST Client
 */
class InsForgeClient {
  constructor() {
    this.baseUrl = INSFORGE_BASE_URL;
    this.apiKey = INSFORGE_API_KEY;
    this.anonKey = INSFORGE_ANON_KEY;
  }

  getHeaders(authToken = null) {
    const token = (authToken || this.apiKey || this.anonKey || '').trim();
    const headers = { 'Content-Type': 'application/json' };
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }
    return headers;
  }

  async fetchFromAuth(endpoint, options = {}) {
    const url = `${this.baseUrl}/api/auth${endpoint}`;
    const response = await fetch(url, {
      ...options,
      headers: {
        ...this.getHeaders(),
        ...options.headers,
      },
      signal: options.signal || AbortSignal.timeout(15_000),
    });

    let payload = null;
    try {
      payload = await response.json();
    } catch (_) {
      payload = null;
    }

    if (!response.ok) {
      const msg = payload?.message || payload?.error || `Auth service returned HTTP ${response.status}`;
      const err = new Error(msg);
      err.statusCode = response.status === 401 || response.status === 403 ? response.status : 502;
      throw err;
    }

    return payload;
  }
}

module.exports = new InsForgeClient();
