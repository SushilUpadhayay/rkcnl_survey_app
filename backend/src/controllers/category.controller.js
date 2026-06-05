const { prisma } = require('../config/db');

// @desc    Create a new category
// @route   POST /api/categories
// @access  Private (Admin)
const createCategory = async (req, res) => {
    try {
        const { name, description } = req.body;

        if (!name) {
            return res.status(400).json({
                success: false,
                message: 'Please provide a category name'
            });
        }

        const existing = await prisma.category.findUnique({ where: { name } });
        if (existing) {
            return res.status(409).json({
                success: false,
                message: 'A category with this name already exists'
            });
        }

        const category = await prisma.category.create({
            data: { 
                name, 
                description: description || null,
                createdById: req.user.id
            }
        });

        res.status(201).json({
            success: true,
            message: 'Category created successfully',
            data: category
        });

    } catch (error) {
        console.error('Create category error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while creating category',
            error: error.message
        });
    }
};

// @desc    Get all categories
// @route   GET /api/categories
// @access  Private
const getAllCategories = async (req, res) => {
    try {
        const { page = 1, limit = 10, search } = req.query;
        const where = {};

        if (search) {
            where.name = { contains: search, mode: 'insensitive' };
        }

        const skip = (parseInt(page) - 1) * parseInt(limit);
        const take = parseInt(limit);

        const [categories, total] = await Promise.all([
            prisma.category.findMany({
                where,
                include: {
                    _count: { select: { surveys: true } }
                },
                orderBy: { name: 'asc' },
                skip,
                take
            }),
            prisma.category.count({ where })
        ]);

        res.status(200).json({
            success: true,
            count: categories.length,
            total,
            page: parseInt(page),
            totalPages: Math.ceil(total / take),
            data: categories
        });

    } catch (error) {
        console.error('Get categories error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching categories',
            error: error.message
        });
    }
};

// @desc    Get a single category by ID
// @route   GET /api/categories/:id
// @access  Private
const getCategoryById = async (req, res) => {
    try {
        const category = await prisma.category.findUnique({
            where: { id: req.params.id },
            include: {
                surveys: {
                    where: { isDeleted: false },
                    select: { id: true, title: true, status: true }
                }
            }
        });

        if (!category) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        res.status(200).json({
            success: true,
            data: category
        });

    } catch (error) {
        console.error('Get category by ID error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching category',
            error: error.message
        });
    }
};

// @desc    Update a category
// @route   PUT /api/categories/:id
// @access  Private (Admin)
const updateCategory = async (req, res) => {
    try {
        const { name, description } = req.body;

        const existing = await prisma.category.findUnique({
            where: { id: req.params.id }
        });

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        const category = await prisma.category.update({
            where: { id: req.params.id },
            data: {
                name: name ?? undefined,
                description: description ?? undefined,
                updatedById: req.user.id
            }
        });

        res.status(200).json({
            success: true,
            message: 'Category updated successfully',
            data: category
        });

    } catch (error) {
        if (error.code === 'P2002') {
            return res.status(409).json({
                success: false,
                message: 'A category with this name already exists'
            });
        }
        console.error('Update category error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while updating category',
            error: error.message
        });
    }
};

// @desc    Delete a category (only if no surveys are linked)
// @route   DELETE /api/categories/:id
// @access  Private (Admin)
const deleteCategory = async (req, res) => {
    try {
        const category = await prisma.category.findUnique({
            where: { id: req.params.id },
            include: { _count: { select: { surveys: true } } }
        });

        if (!category) {
            return res.status(404).json({
                success: false,
                message: 'Category not found'
            });
        }

        if (category._count.surveys > 0) {
            return res.status(400).json({
                success: false,
                message: `Cannot delete category: ${category._count.surveys} survey(s) are linked to it. Reassign them first.`
            });
        }

        await prisma.category.delete({ where: { id: req.params.id } });

        res.status(200).json({
            success: true,
            message: 'Category deleted successfully'
        });

    } catch (error) {
        console.error('Delete category error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while deleting category',
            error: error.message
        });
    }
};

module.exports = {
    createCategory,
    getAllCategories,
    getCategoryById,
    updateCategory,
    deleteCategory
};
