const { prisma } = require('../config/db');

// @desc    Get dashboard statistics
// @route   GET /api/dashboard/stats
// @access  Private (Admin)
const getStats = async (req, res) => {
    try {
        const [
            totalUsers,
            activeUsers,
            totalSurveys,
            activeSurveys,
            totalResponses
        ] = await Promise.all([
            prisma.user.count({ where: { isDeleted: false } }),
            prisma.user.count({ where: { isDeleted: false, isActive: true } }),
            prisma.survey.count({ where: { isDeleted: false } }),
            prisma.survey.count({ where: { isDeleted: false, status: 'Active' } }),
            prisma.response.count()
        ]);

        res.status(200).json({
            success: true,
            data: {
                totalUsers,
                activeUsers,
                totalSurveys,
                activeSurveys,
                totalResponses
            }
        });
    } catch (error) {
        console.error('Get stats error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching statistics',
            error: error.message
        });
    }
};

module.exports = { getStats };
