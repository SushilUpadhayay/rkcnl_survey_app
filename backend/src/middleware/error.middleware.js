// @desc    Global Error Handler
const errorHandler = (err, req, res, next) => {
    console.error(`[Error] ${err.message}`);

    const statusCode = err.statusCode || 500;
    const message = err.message || 'Internal Server Error';

    // Handle specific error types
    if (err.name === 'ZodError') {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors: err.errors.map(e => ({ path: e.path.join('.'), message: e.message }))
        });
    }

    if (err.code === 'P2002') {
        // Prisma unique constraint violation
        return res.status(409).json({
            success: false,
            message: 'A record with this data already exists',
            target: err.meta?.target
        });
    }

    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
};

module.exports = { errorHandler };
