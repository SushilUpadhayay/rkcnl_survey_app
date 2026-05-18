const express = require('express');
const router = express.Router();
const { syncResponses } = require('../controllers/response.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   POST /api/responses/sync
// @desc    Offline sync responses
// @access  Private
router.post('/sync', protect, syncResponses);

module.exports = router;
