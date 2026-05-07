/**
 * src/config/db.js
 * 
 * Database configuration.
 * Responsibilities:
 * - Establish connection to MongoDB using Mongoose
 * - Handle connection errors
 */

const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      // mongoose 6+ defaults are fine, no need for useNewUrlParser/useUnifiedTopology
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1); // Exit process with failure
  }
};

module.exports = connectDB;
