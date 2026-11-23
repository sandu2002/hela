const express = require('express');
const router = express.Router();
const rideController = require('../controllers/rideController');

router.post('/calculate-fare', rideController.calculateFairFare);
router.get('/history/:userId', rideController.getRideHistory);

module.exports = router;
