const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { requireAuth } = require('../middleware/authMiddleware');
const { createRateLimiter } = require('../middleware/rateLimit');

const authLimiter = createRateLimiter({ windowMs: 60_000, max: 30 });

router.get('/session', authLimiter, authController.verifySession);
router.get('/profile/:userId', authLimiter, requireAuth, authController.getProfile);
router.post('/profile/sync', authLimiter, requireAuth, authController.syncProfile);

module.exports = router;
