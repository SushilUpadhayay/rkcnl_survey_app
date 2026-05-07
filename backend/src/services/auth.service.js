/**
 * src/services/auth.service.js
 * 
 * Authentication service.
 * Responsibilities:
 * - Implement business logic for authentication
 * - Interact with the database (models)
 * - Generate JWT tokens
 * - Hash and verify passwords
 */

const jwt = require('jsonwebtoken');

// Example placeholder service functions
// In a real application, you would interact with a User mongoose model here

const loginUser = async (email, password) => {
  // TODO: Validate user against database
  if (email !== 'admin@rkcnl.gov.np' || password !== 'password123') {
    throw new Error('Invalid email or password');
  }

  // Generate token
  const token = jwt.sign(
    { id: 'user_123', email },
    process.env.JWT_SECRET || 'secret',
    { expiresIn: '1d' }
  );

  return {
    user: { id: 'user_123', email, name: 'Admin User' },
    token
  };
};

const registerUser = async (userData) => {
  // TODO: Implement user registration logic with bcrypt hashing
  return {
    id: 'user_new',
    email: userData.email,
    name: userData.name
  };
};

module.exports = {
  loginUser,
  registerUser
};
