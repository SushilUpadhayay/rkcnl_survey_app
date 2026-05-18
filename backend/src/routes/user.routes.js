const express = require('express');
const router = express.Router();
const { updateUser } = require('../controllers/user.controller');
const { protect } = require('../middleware/auth.middleware');

// @route   PUT /api/users/:id
// @desc    Update user
// @access  Private
router.put('/:id', protect, updateUser);

module.exports = router;
