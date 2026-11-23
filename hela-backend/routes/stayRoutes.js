const express = require('express');
const router = express.Router();
const stayController = require('../controllers/stayController');

router.get('/', stayController.getAllStays);

module.exports = router;
