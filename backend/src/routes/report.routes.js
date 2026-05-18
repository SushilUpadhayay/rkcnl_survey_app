const express = require('express');
const router = express.Router();
const { getStats } = require('../controllers/report.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   GET /api/reports/stats
// @desc    Get dashboard statistics
// @access  Private
router.get('/stats', protect, getStats);

module.exports = router;
