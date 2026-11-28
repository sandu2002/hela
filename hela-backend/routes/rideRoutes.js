const express = require('express');
const router = express.Router();
const rideController = require('../controllers/rideController');
const { requireAuth, optionalAuth } = require('../middleware/authMiddleware');
const { createRateLimiter } = require('../middleware/rateLimit');

const rideLimiter = createRateLimiter({ windowMs: 60_000, max: 40 });

router.post('/calculate-fare', rideLimiter, optionalAuth, rideController.calculateFairFare);
router.get('/history/:userId', rideLimiter, requireAuth, rideController.getRideHistory);

module.exports = router;
