const express = require('express');
const router = express.Router();
const tourController = require('../controllers/tourController');
const { requireAuth } = require('../middleware/authMiddleware');
const { createRateLimiter } = require('../middleware/rateLimit');

const aiLimiter = createRateLimiter({ windowMs: 60_000, max: 20 });

router.post('/generate', aiLimiter, tourController.generateTour);
router.post('/chat', aiLimiter, tourController.chatAskHela);
router.post('/save', requireAuth, tourController.saveTourPlan);
router.get('/user/:userId', requireAuth, tourController.getUserTourPlans);

module.exports = router;
