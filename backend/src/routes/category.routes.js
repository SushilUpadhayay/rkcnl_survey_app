const express = require('express');
const router = express.Router();
const {
    createCategory,
    getAllCategories,
    getCategoryById,
    updateCategory,
    deleteCategory
} = require('../controllers/category.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   GET /api/categories
// @desc    Get all categories
// @access  Private
router.get('/', protect, getAllCategories);

// @route   GET /api/categories/:id
// @desc    Get category by ID (includes linked surveys)
// @access  Private
router.get('/:id', protect, getCategoryById);

// @route   POST /api/categories
// @desc    Create a new category
// @access  Private (Admin)
router.post('/', protect, authorize('Admin'), createCategory);

// @route   PUT /api/categories/:id
// @desc    Update a category
// @access  Private (Admin)
router.put('/:id', protect, authorize('Admin'), updateCategory);

// @route   DELETE /api/categories/:id
// @desc    Delete a category (blocked if surveys are linked)
// @access  Private (Admin)
router.delete('/:id', protect, authorize('Admin'), deleteCategory);

module.exports = router;
