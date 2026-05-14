const { prisma } = require('../config/db');

// @desc    Get global stats for admin dashboard
// @route   GET /api/reports/stats
// @access  Private (Admin)
const getStats = async (req, res) => {
    try {
        const [totalSurveys, activeSurveys, totalResponses, totalUsers, fieldStaff] =
            await Promise.all([
                prisma.survey.count({ where: { isDeleted: false } }),
                prisma.survey.count({ where: { isDeleted: false, status: 'Active' } }),
                prisma.response.count(),
                prisma.user.count(),
                prisma.user.count({ where: { role: 'FieldStaff', isActive: true } })
            ]);

        res.status(200).json({
            success: true,
            data: {
                surveys: { total: totalSurveys, active: activeSurveys },
                responses: { total: totalResponses },
                users: { total: totalUsers, fieldStaff }
            }
        });

    } catch (error) {
        console.error('Stats error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error fetching stats',
            error: error.message
        });
    }
};

module.exports = { getStats };
