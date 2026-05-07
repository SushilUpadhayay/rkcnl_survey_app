/**
 * server.js
 * 
 * Main entry point for the backend API.
 * Responsibilities:
 * - Load environment variables
 * - Connect to the database
 * - Start the Express server
 */

require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/db');

const PORT = process.env.PORT || 3000;

// Connect to MongoDB
connectDB();

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
