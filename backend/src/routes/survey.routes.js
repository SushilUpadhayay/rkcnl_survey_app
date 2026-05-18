const express = require('express');
const router = express.Router();
const { getAssignedSurveys } = require('../controllers/survey.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   GET /api/surveys/assigned
// @desc    Get active surveys assigned to the authenticated FieldStaff user
// @access  Private
router.get('/assigned', protect, getAssignedSurveys);

module.exports = router;
