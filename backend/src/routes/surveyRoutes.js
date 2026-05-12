const express = require('express');
const router = express.Router();
const surveyController = require('../controllers/surveyController');
const { protect } = require('../middleware/authMiddleware');

// All survey routes require authentication
router.use(protect);

router.get('/', surveyController.getSurveys);
router.get('/:id', surveyController.getSurveyById);
router.post('/', surveyController.createSurvey);
router.put('/:id', surveyController.updateSurvey);
router.delete('/:id', surveyController.deleteSurvey);

module.exports = router;
