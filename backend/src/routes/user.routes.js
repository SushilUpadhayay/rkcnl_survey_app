const express = require('express');
const router = express.Router();
const {
    getAllUsers,
    getUserById,
    updateUser,
    toggleUserStatus,
    deleteUser,
    approveUser,
    rejectUser
} = require('../controllers/user.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

// @route   GET /api/users
// @desc    Get all users (with optional ?role=, ?isActive=, ?status= filters)
// @access  Private (Admin)
router.get('/', protect, authorize('Admin'), getAllUsers);

// @route   GET /api/users/:id
// @desc    Get a single user by ID
// @access  Private (Admin)
router.get('/:id', protect, authorize('Admin'), getUserById);

// @route   PUT /api/users/:id
// @desc    Update user (Admin: profile fields only; FieldStaff: own fullName only)
// @access  Private
router.put('/:id', protect, updateUser);

// @route   PATCH /api/users/:id/status
// @desc    Toggle user active/inactive status
// @access  Private (Admin)
router.patch('/:id/status', protect, authorize('Admin'), toggleUserStatus);

// @route   PATCH /api/users/:id/approve
// @desc    Approve a pending user
// @access  Private (Admin)
router.patch('/:id/approve', protect, authorize('Admin'), approveUser);

// @route   PATCH /api/users/:id/reject
// @desc    Reject a pending user
// @access  Private (Admin)
router.patch('/:id/reject', protect, authorize('Admin'), rejectUser);

// @route   DELETE /api/users/:id
// @desc    Delete a user permanently
// @access  Private (Admin)
router.delete('/:id', protect, authorize('Admin'), deleteUser);

module.exports = router;
