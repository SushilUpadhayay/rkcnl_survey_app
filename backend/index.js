require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./src/config/db');

// Route Imports
const authRoutes = require('./src/routes/authRoutes');
const surveyRoutes = require('./src/routes/surveyRoutes');
const responseRoutes = require('./src/routes/responseRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to MongoDB Placeholder
connectDB();

app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/surveys', surveyRoutes);
app.use('/api/responses', responseRoutes);

// Health Check
app.get('/api/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date() });
});

app.listen(PORT, () => {
    console.log(`RKCNL Survey App Backend running on port ${PORT}`);
});
