const { prisma } = require('../config/db');

// @desc    Get surveys assigned to the authenticated FieldStaff user
// @route   GET /api/surveys/assigned
// @access  Private
const getAssignedSurveys = async (req, res) => {
    try {
        const assignments = await prisma.surveyAssignment.findMany({
            where: {
                userId: req.user.id
            },
            include: {
                survey: {
                    include: {
                        category: { select: { id: true, name: true } }
                    }
                }
            }
        });

        const surveys = assignments
            .map(a => a.survey)
            .filter(s => !s.isDeleted && s.status === 'Active');

        res.status(200).json({
            success: true,
            count: surveys.length,
            data: surveys
        });

    } catch (error) {
        console.error('Get assigned surveys error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching assigned surveys',
            error: error.message
        });
    }
};

module.exports = { getAssignedSurveys };
