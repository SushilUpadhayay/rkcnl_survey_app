const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const connectDB = async () => {
    try {
<<<<<<< Updated upstream
        await prisma.$connect();
        console.log('PostgreSQL Connected via Prisma');
    } catch (error) {
        console.error(`Error connecting to PostgreSQL: ${error.message}`);
        // In production, you might not want to exit immediately, but for setup it's fine
        // process.exit(1);
=======
        const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/rkcnl_intel');
        console.log(`RKCNL DB System Online: ${conn.connection.host}`);
    } catch (error) {
        console.error(`ERROR: Critical Database Failure: ${error.message}`);
        // In production, we might want to retry or alert admins
        process.exit(1);
>>>>>>> Stashed changes
    }
};

module.exports = { connectDB, prisma };
