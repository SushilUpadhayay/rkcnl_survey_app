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
const dashboardRoutes = require('./routes/dashboard.routes');
const userRoutes = require('./routes/user.routes');
const responseRoutes = require('./routes/response.routes');
const categoryRoutes = require('./routes/category.routes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/surveys', surveyRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/users', userRoutes);
app.use('/api/responses', responseRoutes);
app.use('/api/categories', categoryRoutes);

// Health check endpoint
app.get('/', (req, res) => {
  res.status(200).json({ message: 'RKCNL Survey API is running.' });
});

module.exports = app;
