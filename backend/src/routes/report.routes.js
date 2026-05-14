const express = require('express');
const router = express.Router();
const { getStats } = require('../controllers/report.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   GET /api/reports/stats
// @desc    Get dashboard statistics (Admin only)
// @access  Private (Admin)
router.get('/stats', protect, authorize('Admin'), getStats);

module.exports = router;
