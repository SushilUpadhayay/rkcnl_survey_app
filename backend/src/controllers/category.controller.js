const { prisma } = require('../config/db');

// @desc    Get all categories
// @route   GET /api/categories
// @access  Public
const getAllCategories = async (req, res) => {
    try {
        const categories = await prisma.category.findMany({
            orderBy: { name: 'asc' },
            select: { id: true, name: true, description: true, createdAt: true }
        });

        res.status(200).json({ success: true, count: categories.length, data: categories });

    } catch (error) {
        console.error('Get categories error:', error.message);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

// @desc    Create a category
// @route   POST /api/categories
// @access  Private (Admin)
const createCategory = async (req, res) => {
    try {
        const { name, description } = req.body;

        if (!name) {
            return res.status(400).json({ success: false, message: 'Category name is required' });
        }

        const category = await prisma.category.create({
            data: { name, description }
        });

        res.status(201).json({ success: true, message: 'Category created', data: category });

    } catch (error) {
        if (error.code === 'P2002') {
            return res.status(409).json({ success: false, message: 'Category name already exists' });
        }
        console.error('Create category error:', error.message);
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

module.exports = { getAllCategories, createCategory };
