const { PrismaClient } = require('@prisma/client');

// Single shared Prisma instance for the entire application
const prisma = new PrismaClient();

// Verify database connection on startup
const connectDB = async () => {
    try {
        await prisma.$connect();
        console.log('PostgreSQL connected successfully via Prisma');
    } catch (error) {
        console.error(`Database connection error: ${error.message}`);
        process.exit(1); // Exit if DB is unreachable
    }
};

module.exports = { prisma, connectDB };
