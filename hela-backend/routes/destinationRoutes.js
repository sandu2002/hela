const express = require('express');
const router = express.Router();
const destinationController = require('../controllers/destinationController');
const { createRateLimiter } = require('../middleware/rateLimit');

const ratingLimiter = createRateLimiter({ windowMs: 60_000, max: 30 });

router.post('/live-rating', ratingLimiter, destinationController.getLiveDestinationRating);
router.get('/', destinationController.getAllDestinations);
router.get('/:id', destinationController.getDestinationById);

module.exports = router;
