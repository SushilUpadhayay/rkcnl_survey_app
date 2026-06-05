const express = require('express');
const router = express.Router();
const { register, login, getProfile } = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');
const { validate } = require('../middleware/validate.middleware');
const { registerSchema, loginSchema } = require('../schemas/auth.schema');

// @route   POST /api/auth/register
// @desc    Register a new FieldStaff user
// @access  Public
router.post('/register', validate(registerSchema), register);

// @route   POST /api/auth/login
// @desc    Authenticate user and return JWT
// @access  Public
router.post('/login', validate(loginSchema), login);

// @route   GET /api/auth/profile
// @desc    Get authenticated user profile
// @access  Private
router.get('/profile', protect, getProfile);

module.exports = router;
