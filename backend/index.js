require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDB } = require('./src/config/db');

// Route Imports
const authRoutes = require('./src/routes/authRoutes');
const surveyRoutes = require('./src/routes/surveyRoutes');
const responseRoutes = require('./src/routes/responseRoutes');
<<<<<<< Updated upstream
const categoryRoutes = require('./src/routes/categoryRoutes');
=======
const dashboardRoutes = require('./src/routes/dashboardRoutes');
>>>>>>> Stashed changes

const app = express();
const PORT = process.env.PORT || 3000;

<<<<<<< Updated upstream
// Connect to PostgreSQL via Prisma
=======
// Connect to MongoDB
>>>>>>> Stashed changes
connectDB();

app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/surveys', surveyRoutes);
app.use('/api/responses', responseRoutes);
<<<<<<< Updated upstream
app.use('/api/categories', categoryRoutes);
=======
app.use('/api/dashboard', dashboardRoutes);
>>>>>>> Stashed changes

// Health Check
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'RKCNL KERNEL ONLINE', 
        timestamp: new Date(),
        node: 'NEPAL-CENTRAL-01'
    });
});

app.listen(PORT, () => {
    console.log(`RKCNL Agriculture Intelligence Backend running on port ${PORT}`);
});
