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

            // Verify survey exists and is not deleted
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

// @desc    Get all responses (Admin view — filterable by surveyId or userId)
// @route   GET /api/responses
// @access  Private (Admin)
const getAllResponses = async (req, res) => {
    try {
        const { surveyId, userId, page = 1, limit = 20 } = req.query;

        const where = {};
        if (surveyId) where.surveyId = surveyId;
        if (userId) where.submittedById = userId;

        const skip = (parseInt(page) - 1) * parseInt(limit);

        const [responses, total] = await Promise.all([
            prisma.response.findMany({
                where,
                include: {
                    survey: { select: { id: true, title: true } },
                    submittedBy: { select: { id: true, username: true, email: true } }
                },
                orderBy: { createdAt: 'desc' },
                skip,
                take: parseInt(limit)
            }),
            prisma.response.count({ where })
        ]);

        res.status(200).json({
            success: true,
            count: responses.length,
            total,
            page: parseInt(page),
            totalPages: Math.ceil(total / parseInt(limit)),
            data: responses
        });

    } catch (error) {
        console.error('Get all responses error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching responses',
            error: error.message
        });
    }
};

// @desc    Get a single response by ID (Admin view)
// @route   GET /api/responses/:id
// @access  Private (Admin)
const getResponseById = async (req, res) => {
    try {
        const response = await prisma.response.findUnique({
            where: { id: req.params.id },
            include: {
                survey: { select: { id: true, title: true, questions: true } },
                submittedBy: { select: { id: true, username: true, email: true } }
            }
        });

        if (!response) {
            return res.status(404).json({
                success: false,
                message: 'Response not found'
            });
        }

        res.status(200).json({
            success: true,
            data: response
        });

    } catch (error) {
        console.error('Get response by ID error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching response',
            error: error.message
        });
    }
};

module.exports = { syncResponses, getAllResponses, getResponseById };
