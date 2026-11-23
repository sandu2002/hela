require('dotenv').config();

const INSFORGE_BASE_URL = process.env.INSFORGE_BASE_URL || 'https://tvf24g8r.us-east.insforge.app';
const INSFORGE_API_KEY = process.env.INSFORGE_API_KEY || 'ik_cab32e75750979d7ab16c1684a35affe';
const INSFORGE_ANON_KEY = process.env.INSFORGE_ANON_KEY || 'anon_4ac1cdd3569c8ba96ee190681daac2c8e6f773475692bd59bb4a0365e6c09aae';

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
    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${authToken || this.apiKey || this.anonKey}`,
    };
  }

  async fetchFromAuth(endpoint, options = {}) {
    const url = `${this.baseUrl}/api/auth${endpoint}`;
    const response = await fetch(url, {
      ...options,
      headers: {
        ...this.getHeaders(),
        ...options.headers,
      },
    });
    return response.json();
  }
}

module.exports = new InsForgeClient();
