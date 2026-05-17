const express = require('express');
const router = express.Router();
const surveyController = require('../controllers/survey.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   GET /api/surveys/assigned
// @desc    Get surveys assigned to the current user
// @access  Private
router.get('/assigned', protect, surveyController.getAssignedSurveys);

// @route   POST /api/surveys
// @desc    Create a new survey (Admin only)
// @access  Private (Admin)
router.post('/', protect, authorize('Admin'), surveyController.createSurvey);

// @route   POST /api/surveys/assign
// @desc    Assign a survey to a user (Admin only)
// @access  Private (Admin)
router.post('/assign', protect, authorize('Admin'), surveyController.assignSurvey);

// @route   GET /api/surveys
// @desc    Get all active surveys
// @access  Public
router.get('/', surveyController.getAllSurveys);

// @route   GET /api/surveys/:id
// @desc    Get survey by ID
// @access  Public
router.get('/:id', surveyController.getSurveyById);

// @route   PUT /api/surveys/:id
// @desc    Update a survey (Admin only)
// @access  Private (Admin)
router.put('/:id', protect, authorize('Admin'), surveyController.updateSurvey);

// @route   DELETE /api/surveys/:id
// @desc    Delete a survey (Admin only)
// @access  Private (Admin)
router.delete('/:id', protect, authorize('Admin'), surveyController.deleteSurvey);

module.exports = router;
