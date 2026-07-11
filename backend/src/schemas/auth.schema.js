const { z } = require('zod');

const registerSchema = z.object({
    fullName: z.string().min(3, 'Full Name must be at least 3 characters').max(100),
    email: z.string().email('Invalid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    gender: z.enum(['Male', 'Female', 'Other']).optional(),
    dateOfBirth: z.string().optional(),
    phone: z.string().optional(),
    location: z.string().optional()
});

const loginSchema = z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required')
});

module.exports = { registerSchema, loginSchema };
