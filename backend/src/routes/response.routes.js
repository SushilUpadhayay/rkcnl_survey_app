const express = require('express');
const router = express.Router();
const { syncResponses, getAllResponses, getResponseById } = require('../controllers/response.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   POST /api/responses/sync
// @desc    Bulk sync offline responses from Flutter
// @access  Private (any authenticated user)
router.post('/sync', protect, syncResponses);

// @route   GET /api/responses
// @desc    Get all responses (filterable by ?surveyId= &userId= &page= &limit=)
// @access  Private (Admin)
router.get('/', protect, authorize('Admin'), getAllResponses);

// @route   GET /api/responses/:id
// @desc    Get a single response by ID
// @access  Private (Admin)
router.get('/:id', protect, authorize('Admin'), getResponseById);

module.exports = router;
