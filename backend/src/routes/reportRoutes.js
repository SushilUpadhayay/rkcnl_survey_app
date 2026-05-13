const express = require('express');
const router = express.Router();
const reportController = require('../controllers/reportController');
const { protect } = require('../middleware/authMiddleware');

// All report routes require authentication
router.use(protect);

// Survey-specific reports
router.get('/survey/:surveyId/summary', reportController.getSurveySummary);
router.get('/survey/:surveyId/export/csv', reportController.exportSurveyCSV);

// Global system reports
router.get('/global/stats', reportController.getGlobalStats);

module.exports = router;
