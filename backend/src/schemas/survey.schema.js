const { z } = require('zod');

const createSurveySchema = z.object({
    title: z.string().min(3, 'Title must be at least 3 characters'),
    description: z.string().optional(),
    status: z.enum(['Draft', 'Active', 'Closed']).optional(),
    questions: z.array(z.any()).optional(),
    categoryId: z.string().uuid('Invalid Category ID').optional().nullable()
});

const updateSurveySchema = createSurveySchema.partial();

const assignSurveySchema = z.object({
    surveyId: z.string().uuid('Invalid Survey ID'),
    userId: z.string().uuid('Invalid User ID')
});

module.exports = { createSurveySchema, updateSurveySchema, assignSurveySchema };
