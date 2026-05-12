/**
 * src/controllers/categoryController.js
 *
 * Full CRUD controller for survey Categories (Admin only).
 */

const { prisma } = require('../config/db');

// ── @route   GET /api/categories
// ── @access  Private
exports.getCategories = async (req, res) => {
    try {
        const categories = await prisma.category.findMany({
            orderBy: { name: 'asc' },
            include: {
                _count: { select: { surveys: true } },
            },
        });
        res.json({ count: categories.length, categories });
    } catch (error) {
        console.error('[getCategories]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   GET /api/categories/:id
// ── @access  Private
exports.getCategoryById = async (req, res) => {
    try {
        const category = await prisma.category.findUnique({
            where: { id: req.params.id },
            include: {
                _count: { select: { surveys: true } },
            },
        });
        if (!category) {
            return res.status(404).json({ message: 'Category not found' });
        }
        res.json(category);
    } catch (error) {
        console.error('[getCategoryById]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   POST /api/categories
// ── @access  Private – Admin only
exports.createCategory = async (req, res) => {
    const { name, description } = req.body;

    if (!name || !name.trim()) {
        return res.status(400).json({ message: 'Category name is required' });
    }

    try {
        const category = await prisma.category.create({
            data: {
                name: name.trim(),
                description: description?.trim() || null,
            },
        });
        res.status(201).json(category);
    } catch (error) {
        if (error.code === 'P2002') {
            return res.status(409).json({ message: 'Category name already exists' });
        }
        console.error('[createCategory]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   PUT /api/categories/:id
// ── @access  Private – Admin only
exports.updateCategory = async (req, res) => {
    const { name, description } = req.body;

    try {
        const existing = await prisma.category.findUnique({ where: { id: req.params.id } });
        if (!existing) {
            return res.status(404).json({ message: 'Category not found' });
        }

        const category = await prisma.category.update({
            where: { id: req.params.id },
            data: {
                ...(name !== undefined && { name: name.trim() }),
                ...(description !== undefined && { description: description?.trim() || null }),
            },
        });
        res.json(category);
    } catch (error) {
        if (error.code === 'P2002') {
            return res.status(409).json({ message: 'Category name already exists' });
        }
        console.error('[updateCategory]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   DELETE /api/categories/:id
// ── @access  Private – Admin only
exports.deleteCategory = async (req, res) => {
    try {
        const existing = await prisma.category.findUnique({ where: { id: req.params.id } });
        if (!existing) {
            return res.status(404).json({ message: 'Category not found' });
        }

        await prisma.category.delete({ where: { id: req.params.id } });
        res.json({ message: 'Category deleted successfully' });
    } catch (error) {
        // P2003: Foreign key constraint (surveys still reference this category)
        if (error.code === 'P2003') {
            return res.status(409).json({ message: 'Cannot delete category: surveys are still linked to it' });
        }
        console.error('[deleteCategory]', error);
        res.status(500).json({ message: error.message });
    }
};
