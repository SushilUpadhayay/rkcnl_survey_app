const express = require('express');
const router = express.Router();
const { getAllCategories, createCategory } = require('../controllers/category.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   GET /api/categories
// @desc    Get all categories
// @access  Public
router.get('/', getAllCategories);

// @route   POST /api/categories
// @desc    Create a category (Admin only)
// @access  Private (Admin)
router.post('/', protect, authorize('Admin'), createCategory);

module.exports = router;
