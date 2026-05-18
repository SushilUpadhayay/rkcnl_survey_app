const express = require('express');
const router = express.Router();
const { getAllCategories, createCategory } = require('../controllers/category.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   GET /api/categories
// @desc    Get all categories
// @access  Public
router.get('/', getAllCategories);

// @route   POST /api/categories
// @desc    Create a category
// @access  Private
router.post('/', protect, createCategory);

module.exports = router;
