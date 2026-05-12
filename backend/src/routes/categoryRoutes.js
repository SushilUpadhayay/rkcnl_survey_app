const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { protect, authorize } = require('../middleware/authMiddleware');

// All category routes require authentication
router.use(protect);

// Read: any authenticated user
router.get('/', categoryController.getCategories);
router.get('/:id', categoryController.getCategoryById);

// Write: Admin only
router.post('/', authorize('Admin'), categoryController.createCategory);
router.put('/:id', authorize('Admin'), categoryController.updateCategory);
router.delete('/:id', authorize('Admin'), categoryController.deleteCategory);

module.exports = router;
