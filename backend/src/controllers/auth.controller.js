const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { prisma } = require('../config/db');

// @desc    Register a new FieldStaff user
// @route   POST /api/auth/register
// @access  Public
const register = async (req, res) => {
    try {
        const { username, gender, dateOfBirth, location, email, phone, password } = req.body;

        const existingUser = await prisma.user.findUnique({ where: { email } });

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'An account with this email already exists'
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        const newUser = await prisma.user.create({
            data: {
                username,
                email,
                gender,
                dateOfBirth,
                location,
                phone,
                passwordHash: hashedPassword
                // role defaults to "FieldStaff" via schema
            },
            select: {
                id: true,
                username: true,
                email: true,
                gender: true,
                dateOfBirth: true,
                location: true,
                phone: true,
                role: true,
                status: true,
                createdAt: true
            }
        });

        res.status(201).json({
            success: true,
            message: 'Account registered successfully. Waiting for admin approval.',
            data: newUser
        });

    } catch (error) {
        console.error('Registration error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error during registration',
            error: error.message
        });
    }
};

// @desc    Authenticate user and return JWT
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await prisma.user.findUnique({ where: { email } });

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        if (user.status === 'Pending') {
            return res.status(401).json({
                success: false,
                message: 'Your account is pending administrator approval.'
            });
        }

        if (user.status === 'Rejected') {
            return res.status(401).json({
                success: false,
                message: 'Your registration request has been rejected.'
            });
        }

        if (user.status !== 'Approved') {
            return res.status(401).json({
                success: false,
                message: 'Your account is not approved to login.'
            });
        }

        if (!user.isActive) {
            return res.status(401).json({
                success: false,
                message: 'Account is inactive. Please contact an administrator.'
            });
        }

        const isMatch = await bcrypt.compare(password, user.passwordHash);

        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        const token = jwt.sign(
            { id: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '30d' }
        );

        res.status(200).json({
            success: true,
            message: 'Login successful',
            token,
            data: {
                id: user.id,
                username: user.username,
                email: user.email,
                role: user.role,
                status: user.status,
                isActive: user.isActive
            }
        });

    } catch (error) {
        console.error('Login error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error during login',
            error: error.message
        });
    }
};

// @desc    Get authenticated user profile
// @route   GET /api/auth/profile
// @access  Private
const getProfile = async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.user.id },
            select: {
                id: true,
                username: true,
                email: true,
                gender: true,
                dateOfBirth: true,
                phone: true,
                location: true,
                role: true,
                status: true,
                isActive: true,
                createdAt: true
            }
        });

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        res.status(200).json({
            success: true,
            message: 'Profile retrieved successfully',
            data: user
        });

    } catch (error) {
        console.error('Get profile error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error retrieving profile',
            error: error.message
        });
    }
};

module.exports = { register, login, getProfile };
