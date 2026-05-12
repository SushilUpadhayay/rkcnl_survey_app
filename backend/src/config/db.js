const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const connectDB = async () => {
    try {
        await prisma.$connect();
        console.log('PostgreSQL Connected via Prisma');
    } catch (error) {
        console.error(`Error connecting to PostgreSQL: ${error.message}`);
        // In production, you might not want to exit immediately, but for setup it's fine
        // process.exit(1);
    }
};

module.exports = { connectDB, prisma };
