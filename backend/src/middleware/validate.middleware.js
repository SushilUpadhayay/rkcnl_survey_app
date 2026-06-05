const validate = (schema) => async (req, res, next) => {
    try {
        await schema.parseAsync(req.body);
        next();
    } catch (error) {
        // Forward ZodError to global error handler
        next(error);
    }
};

module.exports = { validate };
