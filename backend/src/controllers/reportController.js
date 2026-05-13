/**
 * src/controllers/reportController.js
 *
 * Provides analytics and data export functionality for surveys.
 * - getSurveySummary: Aggregated statistics for a specific survey.
 * - exportSurveyCSV: Generates and streams a CSV of all survey responses.
 * - getGlobalStats: Overview stats across the entire system.
 */

const { prisma } = require('../config/db');

// ── @route   GET /api/reports/survey/:surveyId/summary
// ── @access  Private – Admin only
exports.getSurveySummary = async (req, res) => {
    if (req.user?.role !== 'Admin') {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    const { surveyId } = req.params;

    try {
        const survey = await prisma.survey.findFirst({
            where: { id: surveyId, isDeleted: false },
            include: { _count: { select: { responses: true } } }
        });

        if (!survey) return res.status(404).json({ message: 'Survey not found' });

        const responses = await prisma.response.findMany({
            where: { surveyId }
        });

        // Basic Aggregations
        const summary = {
            surveyTitle: survey.title,
            totalResponses: survey._count.responses,
            latestResponse: responses.length > 0 ? responses[0].createdAt : null,
            // Example: Analysis of numeric answers if applicable
            questionStats: {}
        };

        // If we want to analyze specific question types (e.g. RatingScale)
        // Note: Questions are stored in JSON, answers in JSON.
        const questions = Array.isArray(survey.questions) ? survey.questions : [];
        
        questions.forEach(q => {
            if (q.type === 'RatingScale') {
                const ratings = responses
                    .map(r => {
                        const ans = r.answers.find(a => a.questionId === q.id);
                        return ans ? parseFloat(ans.value) : null;
                    })
                    .filter(v => v !== null);

                if (ratings.length > 0) {
                    const sum = ratings.reduce((a, b) => a + b, 0);
                    summary.questionStats[q.id] = {
                        text: q.text,
                        average: (sum / ratings.length).toFixed(2),
                        count: ratings.length
                    };
                }
            }
        });

        res.json(summary);
    } catch (error) {
        console.error('[getSurveySummary]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   GET /api/reports/survey/:surveyId/export/csv
// ── @access  Private – Admin only
exports.exportSurveyCSV = async (req, res) => {
    if (req.user?.role !== 'Admin') {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    const { surveyId } = req.params;

    try {
        const survey = await prisma.survey.findFirst({
            where: { id: surveyId, isDeleted: false }
        });

        if (!survey) return res.status(404).json({ message: 'Survey not found' });

        const responses = await prisma.response.findMany({
            where: { surveyId },
            include: { submittedBy: { select: { username: true } } },
            orderBy: { createdAt: 'desc' }
        });

        const questions = Array.isArray(survey.questions) ? survey.questions : [];

        // Build CSV Header
        let csv = 'ResponseID,SubmittedBy,Timestamp,' + questions.map(q => `"${q.text.replace(/"/g, '""')}"`).join(',') + '\n';

        // Build CSV Rows
        responses.forEach(r => {
            let row = [
                r.id,
                r.submittedBy?.username || 'Unknown',
                r.createdAt.toISOString()
            ];

            questions.forEach(q => {
                const ans = r.answers.find(a => a.questionId === q.id);
                let val = ans ? ans.value : '';
                
                // Format complex values (Lists, Maps)
                if (typeof val === 'object' && val !== null) {
                    val = JSON.stringify(val);
                }
                
                row.push(`"${String(val).replace(/"/g, '""')}"`);
            });

            csv += row.join(',') + '\n';
        });

        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', `attachment; filename=survey_${surveyId}_export.csv`);
        res.status(200).send(csv);
    } catch (error) {
        console.error('[exportSurveyCSV]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   GET /api/reports/global/stats
// ── @access  Private – Admin only
exports.getGlobalStats = async (req, res) => {
    if (req.user?.role !== 'Admin') {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    try {
        const [userCount, surveyCount, responseCount, recentResponses] = await prisma.$transaction([
            prisma.user.count(),
            prisma.survey.count({ where: { isDeleted: false } }),
            prisma.response.count(),
            prisma.response.findMany({
                take: 5,
                orderBy: { createdAt: 'desc' },
                include: { survey: { select: { title: true } } }
            })
        ]);

        res.json({
            users: userCount,
            surveys: surveyCount,
            responses: responseCount,
            recentActivity: recentResponses.map(r => ({
                id: r.id,
                surveyTitle: r.survey.title,
                timestamp: r.createdAt
            }))
        });
    } catch (error) {
        console.error('[getGlobalStats]', error);
        res.status(500).json({ message: error.message });
    }
};
