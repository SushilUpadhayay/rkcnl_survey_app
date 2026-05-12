const express = require('express');
const router = express.Router();
const responseController = require('../controllers/responseController');

// Define response routes mapping to controller placeholders
// TODO: Add auth middleware later
router.post('/sync', responseController.syncResponses);
router.get('/survey/:surveyId', responseController.getResponsesBySurvey);

module.exports = router;
