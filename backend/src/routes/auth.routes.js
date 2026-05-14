const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   POST /api/auth/register
// @desc    Register a new user (Placeholder)
// @access  Public
router.post('/register', authController.register);

// @route   POST /api/auth/login
// @desc    Authenticate user and log in (Placeholder)
// @access  Public
router.post('/login', authController.login);

// @route   GET /api/auth/profile
// @desc    Get user profile from token
// @access  Private
router.get('/profile', protect, authController.getProfile);

module.exports = router;
