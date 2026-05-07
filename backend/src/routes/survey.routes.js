/**
 * src/routes/survey.routes.js
 * 
 * Survey routes.
 * Responsibilities:
 * - Define API endpoints for survey operations
 * - Map routes to controller functions
 */

const express = require('express');
const router = express.Router();
const surveyController = require('../controllers/survey.controller');

// @route   GET /v1/surveys
// @desc    Get all surveys
router.get('/', surveyController.getSurveys);

module.exports = router;
