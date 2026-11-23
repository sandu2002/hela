const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.get('/session', authController.verifySession);
router.get('/profile/:userId', authController.getProfile);
router.post('/profile/sync', authController.syncProfile);

module.exports = router;
