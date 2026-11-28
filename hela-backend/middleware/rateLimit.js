/**
 * Bounded in-memory sliding-window IP rate limiter.
 */
function createRateLimiter({
  windowMs = 60 * 1000,
  max = 30,
  maxTrackedKeys = 5000,
  message = 'Too many requests, please try again shortly.',
} = {}) {
  const hits = new Map();

  return function rateLimiter(req, res, next) {
    const key =
      (req.ip || req.headers?.['x-forwarded-for'] || 'unknown').toString().split(',')[0].trim();
    const now = Date.now();

    let entry = hits.get(key);
    if (!entry || now >= entry.resetAt) {
      if (!entry && hits.size >= maxTrackedKeys) {
        const oldestKey = hits.keys().next().value;
        if (oldestKey !== undefined) hits.delete(oldestKey);
      }
      entry = { count: 0, resetAt: now + windowMs };
    }

    entry.count += 1;
    hits.set(key, entry);

    const remaining = Math.max(0, max - entry.count);
    res.setHeader?.('X-RateLimit-Limit', String(max));
    res.setHeader?.('X-RateLimit-Remaining', String(remaining));

    if (entry.count > max) {
      const retryAfterSec = Math.max(1, Math.ceil((entry.resetAt - now) / 1000));
      res.setHeader?.('Retry-After', String(retryAfterSec));
      return res.status(429).json({ error: message });
    }

    return next();
  };
}

module.exports = { createRateLimiter };
