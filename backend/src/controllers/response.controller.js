const { prisma } = require('../config/db');

// @desc    Submit bulk survey responses from Flutter (offline sync)
// @route   POST /api/responses/sync
// @access  Private
const syncResponses = async (req, res) => {
    try {
        const { responses } = req.body;

        if (!responses || !Array.isArray(responses) || responses.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'No responses provided'
            });
        }

        const results = [];

        for (const item of responses) {
            const { surveyId, deviceTimestamp, answers, customQuestions, personalNotes, latitude, longitude, photos } = item;

            if (!surveyId || !deviceTimestamp) {
                results.push({ surveyId, success: false, message: 'Missing surveyId or deviceTimestamp' });
                continue;
            }

            // Verify survey exists
            const survey = await prisma.survey.findFirst({
                where: { id: surveyId, isDeleted: false }
            });

            if (!survey) {
                results.push({ surveyId, success: false, message: 'Survey not found' });
                continue;
            }

            try {
                const response = await prisma.response.create({
                    data: {
                        surveyId,
                        submittedById: req.user.id,
                        deviceTimestamp: new Date(deviceTimestamp),
                        answers: answers ?? [],
                        customQuestions: customQuestions ?? [],
                        personalNotes: personalNotes ?? '',
                        latitude: latitude !== undefined ? parseFloat(latitude) : null,
                        longitude: longitude !== undefined ? parseFloat(longitude) : null,
                        photos: photos ?? []
                    }
                });
                results.push({ surveyId, responseId: response.id, success: true });
            } catch (err) {
                results.push({ surveyId, success: false, message: err.message });
            }
        }

        const allSuccess = results.every(r => r.success);
        const anySuccess = results.some(r => r.success);

        res.status(anySuccess ? (allSuccess ? 200 : 207) : 400).json({
            success: anySuccess,
            message: allSuccess
                ? 'All responses synced successfully'
                : 'Partial sync — some responses failed',
            results
        });

    } catch (error) {
        console.error('Sync error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error during sync',
            error: error.message
        });
    }
};

// @desc    Get all responses (admin only)
// @route   GET /api/responses
// @access  Private (Admin)
const getAllResponses = async (req, res) => {
    try {
        const { surveyId } = req.query;

        const responses = await prisma.response.findMany({
            where: surveyId ? { surveyId } : {},
            orderBy: { createdAt: 'desc' },
            include: {
                survey: { select: { id: true, title: true } },
                submittedBy: { select: { id: true, username: true, email: true } }
            }
        });

        res.status(200).json({
            success: true,
            count: responses.length,
            data: responses
        });

    } catch (error) {
        console.error('Get responses error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error fetching responses',
            error: error.message
        });
    }
};

module.exports = { syncResponses, getAllResponses };
