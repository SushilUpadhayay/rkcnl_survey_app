require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB } = require('./src/config/db');

// Route Imports
const authRoutes = require('./src/routes/auth.routes');
const surveyRoutes = require('./src/routes/survey.routes');
const responseRoutes = require('./src/routes/response.routes');
const userRoutes = require('./src/routes/user.routes');
const reportRoutes = require('./src/routes/report.routes');
const categoryRoutes = require('./src/routes/category.routes');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to database
connectDB();

app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/surveys', surveyRoutes);
app.use('/api/responses', responseRoutes);
app.use('/api/users', userRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/categories', categoryRoutes);

// Health Check
app.get('/api/health', (req, res) => {
    res.json({
        success: true,
        status: 'RKCNL Backend Online',
        timestamp: new Date(),
        environment: process.env.NODE_ENV
    });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
