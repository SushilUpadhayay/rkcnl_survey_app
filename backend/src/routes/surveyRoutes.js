const express = require('express');
const router = express.Router();
<<<<<<< Updated upstream
const surveyController = require('../controllers/surveyController');
const { protect } = require('../middleware/authMiddleware');

// All survey routes require authentication
router.use(protect);

router.get('/', surveyController.getSurveys);
router.get('/:id', surveyController.getSurveyById);
router.post('/', surveyController.createSurvey);
router.put('/:id', surveyController.updateSurvey);
router.delete('/:id', surveyController.deleteSurvey);
=======
const { createSurvey, getSurveys } = require('../controllers/surveyController');
const { protect, admin } = require('../middleware/authMiddleware');

router.route('/')
    .get(protect, getSurveys)
    .post(protect, createSurvey);
>>>>>>> Stashed changes

module.exports = router;
