const express = require('express');
const router = express.Router();
const destinationController = require('../controllers/destinationController');

router.post('/live-rating', destinationController.getLiveDestinationRating);
router.get('/', destinationController.getAllDestinations);
router.get('/:id', destinationController.getDestinationById);

module.exports = router;
