const express = require('express');
const router = express.Router();
const tourController = require('../controllers/tourController');

router.post('/generate', tourController.generateTour);
router.post('/save', tourController.saveTourPlan);
router.get('/user/:userId', tourController.getUserTourPlans);

module.exports = router;
