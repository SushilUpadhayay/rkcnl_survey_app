/**
 * src/controllers/auth.controller.js
 * 
 * Authentication controller.
 * Responsibilities:
 * - Handle incoming HTTP requests for authentication
 * - Call the appropriate service functions
 * - Send HTTP responses back to the client
 * - Keep controllers thin; business logic belongs in services
 */

const authService = require('../services/auth.service');

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    // Delegate business logic to service
    const result = await authService.loginUser(email, password);
    
    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: error.message
    });
  }
};

const register = async (req, res) => {
  try {
    const userData = req.body;
    // Delegate business logic to service
    const result = await authService.registerUser(userData);
    
    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = {
  login,
  register
};
