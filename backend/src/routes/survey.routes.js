const express = require('express');
const router = express.Router();
const {
    createSurvey,
    getAllSurveys,
    getSurveyById,
    getAssignedSurveys,
    assignSurvey,
    unassignSurvey,
    getAssignments,
    updateSurvey,
    deleteSurvey
} = require('../controllers/survey.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// ─── FieldStaff Routes ────────────────────────────────────────────────────────

// @route   GET /api/surveys/assigned
// @desc    Get active surveys assigned to the authenticated user
// @access  Private (any authenticated user)
router.get('/assigned', protect, getAssignedSurveys);

// ─── Admin-only Routes ────────────────────────────────────────────────────────

// @route   GET /api/surveys
// @desc    Get all surveys (all statuses, with filters)
// @access  Private (Admin)
router.get('/', protect, authorize('Admin'), getAllSurveys);

// @route   POST /api/surveys
// @desc    Create a new survey
// @access  Private (Admin)
router.post('/', protect, authorize('Admin'), createSurvey);

// @route   GET /api/surveys/assignments
// @desc    Get all survey assignments (filterable by surveyId or userId)
// @access  Private (Admin)
router.get('/assignments', protect, authorize('Admin'), getAssignments);

// @route   POST /api/surveys/assign
// @desc    Assign a survey to a user
// @access  Private (Admin)
router.post('/assign', protect, authorize('Admin'), assignSurvey);

// @route   DELETE /api/surveys/assign
// @desc    Unassign a survey from a user
// @access  Private (Admin)
router.delete('/assign', protect, authorize('Admin'), unassignSurvey);

// @route   GET /api/surveys/:id
// @desc    Get a single survey by ID
// @access  Private (Admin)
router.get('/:id', protect, authorize('Admin'), getSurveyById);

// @route   PUT /api/surveys/:id
// @desc    Update a survey
// @access  Private (Admin)
router.put('/:id', protect, authorize('Admin'), updateSurvey);

// @route   DELETE /api/surveys/:id
// @desc    Soft delete a survey
// @access  Private (Admin)
router.delete('/:id', protect, authorize('Admin'), deleteSurvey);

module.exports = router;
