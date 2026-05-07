/**
 * src/app.js
 * 
 * Express application setup.
 * Responsibilities:
 * - Configure middlewares (CORS, JSON parsing)
 * - Register API routes
 * - Centralized error handling setup
 */

const express = require('express');
const cors = require('cors');

// Import routes
const authRoutes = require('./routes/auth.routes');
const surveyRoutes = require('./routes/survey.routes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
// Using /v1 API versioning strategy as requested
app.use('/v1/auth', authRoutes);
app.use('/v1/surveys', surveyRoutes);

// Health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({ message: 'RKCNL Survey API is running.' });
});

module.exports = app;
