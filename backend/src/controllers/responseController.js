/**
 * src/controllers/responseController.js
 *
 * Handles survey responses:
 *   - Bulk offline sync from mobile (FieldStaff)
 *   - Fetch responses for a survey (Admin)
 */

const { prisma } = require('../config/db');

// ── @route   POST /api/responses/sync
// ── @access  Private (FieldStaff)
// ── @body    { responses: [ { surveyId, deviceTimestamp, answers, customQuestions, personalNotes } ] }
exports.syncResponses = async (req, res) => {
    const { responses } = req.body;

    if (!Array.isArray(responses) || responses.length === 0) {
        return res.status(400).json({ message: 'responses array is required and must not be empty' });
    }

    const synced = [];
    const failed = [];

    for (const item of responses) {
        const { surveyId, deviceTimestamp, answers, customQuestions, personalNotes } = item;

        // Basic validation
        if (!surveyId || !deviceTimestamp || !Array.isArray(answers)) {
            failed.push({ item, reason: 'Missing required fields: surveyId, deviceTimestamp, answers[]' });
            continue;
        }

        // Verify survey exists and is active
        const survey = await prisma.survey.findFirst({
            where: { id: surveyId, status: 'Active', isDeleted: false },
        }).catch(() => null);

        if (!survey) {
            failed.push({ item, reason: `Survey not found or not active: ${surveyId}` });
            continue;
        }

        try {
            const response = await prisma.response.create({
                data: {
                    surveyId,
                    deviceTimestamp: new Date(deviceTimestamp),
                    answers: answers || [],
                    customQuestions: customQuestions || [],
                    personalNotes: personalNotes || null,
                    submittedById: req.user.id,
                },
            });

            synced.push(response.id);
        } catch (err) {
            console.error('[syncResponses] failed to save response:', err.message);
            failed.push({ item, reason: err.message });
        }
    }

    const status = failed.length === 0 ? 200 : synced.length > 0 ? 207 : 400;
    res.status(status).json({
        synced: synced.length,
        failed: failed.length,
        syncedIds: synced,
        ...(failed.length > 0 && { errors: failed }),
    });
};

// ── @route   GET /api/responses/survey/:surveyId
// ── @access  Private – Admin only
exports.getResponsesBySurvey = async (req, res) => {
    if (req.user?.role !== 'Admin') {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    const { surveyId } = req.params;
    const { page = 1, limit = 50 } = req.query;

    try {
        const survey = await prisma.survey.findFirst({
            where: { id: surveyId, isDeleted: false },
        });

        if (!survey) {
            return res.status(404).json({ message: 'Survey not found' });
        }

        const skip = (Number(page) - 1) * Number(limit);

        const [total, responses] = await prisma.$transaction([
            prisma.response.count({ where: { surveyId } }),
            prisma.response.findMany({
                where: { surveyId },
                skip,
                take: Number(limit),
                orderBy: { deviceTimestamp: 'desc' },
                include: {
                    submittedBy: { select: { id: true, username: true } },
                },
            }),
        ]);

        res.json({
            surveyId,
            total,
            page: Number(page),
            limit: Number(limit),
            responses,
        });
    } catch (error) {
        console.error('[getResponsesBySurvey]', error);
        res.status(500).json({ message: error.message });
    }
};
