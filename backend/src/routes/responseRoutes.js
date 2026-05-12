const express = require('express');
const router = express.Router();
const responseController = require('../controllers/responseController');
const { protect } = require('../middleware/authMiddleware');

// All response routes require authentication
router.use(protect);

router.post('/sync', responseController.syncResponses);
router.get('/survey/:surveyId', responseController.getResponsesBySurvey);

module.exports = router;
