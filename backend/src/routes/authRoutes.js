const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Define auth routes mapping to controller placeholders
router.post('/login', authController.login);
router.get('/me', authController.getMe); // TODO: Add auth middleware later

module.exports = router;
