const express = require('express');
const router = express.Router();
const surveyController = require('../controllers/survey.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   GET /api/surveys/assigned
// @desc    Get surveys assigned to the current user
// @access  Private
router.get('/assigned', protect, surveyController.getAssignedSurveys);

// @route   POST /api/surveys
// @desc    Create a new survey
// @access  Private
router.post('/', protect, surveyController.createSurvey);

// @route   POST /api/surveys/assign
// @desc    Assign a survey to a user
// @access  Private
router.post('/assign', protect, surveyController.assignSurvey);

// @route   GET /api/surveys
// @desc    Get all active surveys
// @access  Public
router.get('/', surveyController.getAllSurveys);

// @route   GET /api/surveys/:id
// @desc    Get survey by ID
// @access  Public
router.get('/:id', surveyController.getSurveyById);

// @route   PUT /api/surveys/:id
// @desc    Update a survey
// @access  Private
router.put('/:id', protect, surveyController.updateSurvey);

// @route   DELETE /api/surveys/:id
// @desc    Delete a survey
// @access  Private
router.delete('/:id', protect, surveyController.deleteSurvey);

module.exports = router;
