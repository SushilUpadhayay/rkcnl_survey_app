const { prisma } = require('../config/db');

// @desc    Update user (self: username)
// @route   PUT /api/users/:id
// @access  Private
const updateUser = async (req, res) => {
    try {
        const { id } = req.params;
        const { username } = req.body;

        const isSelf = req.user.id === id;

        if (!isSelf) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized to update this user'
            });
        }

        const updateData = {};
        if (username) updateData.username = username;

        const updated = await prisma.user.update({
            where: { id },
            data: updateData,
            select: {
                id: true,
                username: true,
                email: true,
                role: true,
                isActive: true,
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

module.exports = { updateUser };
