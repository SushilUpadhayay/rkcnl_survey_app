/**
 * src/controllers/survey.controller.js
 * 
 * Survey controller.
 * Responsibilities:
 * - Handle incoming HTTP requests for surveys
 * - Call the appropriate service functions
 * - Send HTTP responses back to the client
 */

const surveyService = require('../services/survey.service');

const getSurveys = async (req, res) => {
  try {
    // Delegate business logic to service
    const surveys = await surveyService.getAllSurveys();
    
    res.status(200).json({
      success: true,
      data: surveys
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = {
  getSurveys
};
