/**
 * src/routes/auth.routes.js
 * 
 * Authentication routes.
 * Responsibilities:
 * - Define API endpoints for authentication (login, register)
 * - Map routes to controller functions
 */

const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// @route   POST /v1/auth/login
// @desc    Authenticate user & get token
router.post('/login', authController.login);

// @route   POST /v1/auth/register
// @desc    Register a new user
router.post('/register', authController.register);

module.exports = router;
