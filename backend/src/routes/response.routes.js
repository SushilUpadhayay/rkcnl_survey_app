const express = require('express');
const router = express.Router();
const { syncResponses, getAllResponses } = require('../controllers/response.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   POST /api/responses/sync
// @desc    Offline sync responses
// @access  Private
router.post('/sync', protect, syncResponses);

// @route   GET /api/responses
// @desc    Get all responses (Admin only)
// @access  Private (Admin)
router.get('/', protect, authorize('Admin'), getAllResponses);

module.exports = router;
