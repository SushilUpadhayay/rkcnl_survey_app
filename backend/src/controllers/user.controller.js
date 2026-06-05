const { prisma } = require('../config/db');

// @desc    Get all users (Admin view)
// @route   GET /api/users
// @access  Private (Admin)
const getAllUsers = async (req, res) => {
    try {
        const { role, isActive } = req.query;
        const where = {};

        if (role) where.role = role;
        if (isActive !== undefined) where.isActive = isActive === 'true';

        const users = await prisma.user.findMany({
            where,
            select: {
                id: true,
                username: true,
                email: true,
                gender: true,
                dateOfBirth: true,
                phone: true,
                location: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
                _count: {
                    select: {
                        responses: true,
                        assignments: true
                    }
                }
            },
            orderBy: { createdAt: 'desc' }
        });

        res.status(200).json({
            success: true,
            count: users.length,
            data: users
        });

    } catch (error) {
        console.error('Get all users error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching users',
            error: error.message
        });
    }
};

// @desc    Get a single user by ID (Admin view)
// @route   GET /api/users/:id
// @access  Private (Admin)
const getUserById = async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.params.id },
            select: {
                id: true,
                username: true,
                email: true,
                gender: true,
                dateOfBirth: true,
                phone: true,
                location: true,
                role: true,
                isActive: true,
                createdAt: true,
                updatedAt: true,
                assignments: {
                    include: {
                        survey: { select: { id: true, title: true, status: true } }
                    }
                },
                _count: {
                    select: { responses: true, assignments: true }
                }
            }
        });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            data: user
        });

    } catch (error) {
        console.error('Get user by ID error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching user',
            error: error.message
        });
    }
};

// @desc    Update user (Admin: any field; Self: only username)
// @route   PUT /api/users/:id
// @access  Private
const updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const isAdmin = req.user.role === 'Admin';
        const isSelf = req.user.id === id;

        if (!isAdmin && !isSelf) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this user'
            });
        }

        const updateData = {};

        if (isAdmin) {
            // Admins can update any field
            const { username, role, isActive, phone, location, gender, dateOfBirth } = req.body;
            if (username !== undefined) updateData.username = username;
            if (role !== undefined) updateData.role = role;
            if (isActive !== undefined) updateData.isActive = isActive;
            if (phone !== undefined) updateData.phone = phone;
            if (location !== undefined) updateData.location = location;
            if (gender !== undefined) updateData.gender = gender;
            if (dateOfBirth !== undefined) updateData.dateOfBirth = dateOfBirth;
        } else {
            // FieldStaff can only update their own username
            const { username } = req.body;
            if (username !== undefined) updateData.username = username;
        }

        if (Object.keys(updateData).length === 0) {
            return res.status(400).json({
                success: false,
                message: 'No valid fields provided for update'
            });
        }

        const updated = await prisma.user.update({
            where: { id },
            data: updateData,
            select: {
                id: true,
                username: true,
                email: true,
                role: true,
                isActive: true,
                phone: true,
                location: true,
                gender: true,
                dateOfBirth: true,
                updatedAt: true
            }
        });

        res.status(200).json({
            success: true,
            message: 'User updated successfully',
            data: updated
        });

    } catch (error) {
        console.error('Update user error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error updating user',
            error: error.message
        });
    }
};

// @desc    Toggle user active status (Admin only)
// @route   PATCH /api/users/:id/status
// @access  Private (Admin)
const toggleUserStatus = async (req, res) => {
    try {
        const user = await prisma.user.findUnique({
            where: { id: req.params.id },
            select: { id: true, isActive: true, username: true }
        });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        const updated = await prisma.user.update({
            where: { id: req.params.id },
            data: { isActive: !user.isActive },
            select: {
                id: true,
                username: true,
                email: true,
                role: true,
                isActive: true
            }
        });

        res.status(200).json({
            success: true,
            message: `User ${updated.isActive ? 'activated' : 'deactivated'} successfully`,
            data: updated
        });

    } catch (error) {
        console.error('Toggle user status error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error toggling user status',
            error: error.message
        });
    }
};

// @desc    Delete a user permanently (Admin only)
// @route   DELETE /api/users/:id
// @access  Private (Admin)
const deleteUser = async (req, res) => {
    try {
        // Prevent admin from deleting themselves
        if (req.params.id === req.user.id) {
            return res.status(400).json({
                success: false,
                message: 'You cannot delete your own account'
            });
        }

        const user = await prisma.user.findUnique({
            where: { id: req.params.id }
        });

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        await prisma.user.delete({ where: { id: req.params.id } });

        res.status(200).json({
            success: true,
            message: 'User deleted successfully'
        });

    } catch (error) {
        console.error('Delete user error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error deleting user',
            error: error.message
        });
    }
};

module.exports = { getAllUsers, getUserById, updateUser, toggleUserStatus, deleteUser };
