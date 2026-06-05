require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB } = require('./src/config/db');

// Route Imports
const authRoutes = require('./src/routes/auth.routes');
const surveyRoutes = require('./src/routes/survey.routes');
const responseRoutes = require('./src/routes/response.routes');
const userRoutes = require('./src/routes/user.routes');
const categoryRoutes = require('./src/routes/category.routes');

const app = express();
const PORT = process.env.PORT || 3000;

connectDB();

app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/surveys', surveyRoutes);
app.use('/api/responses', responseRoutes);
app.use('/api/users', userRoutes);
app.use('/api/categories', categoryRoutes);

// Health Check
app.get('/api/health', (req, res) => {
    res.json({
        success: true,
        status: 'RKCNL Survey Backend Online',
        timestamp: new Date(),
        environment: process.env.NODE_ENV
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: `Route not found: ${req.method} ${req.originalUrl}`
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

app.listen(PORT, () => {
    console.log(`✅ RKCNL Survey Backend running on port ${PORT}`);
    console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);
});
