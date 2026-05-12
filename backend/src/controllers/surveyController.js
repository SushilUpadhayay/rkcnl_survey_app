/**
 * src/controllers/surveyController.js
 *
 * Full CRUD controller for Surveys using Prisma + PostgreSQL.
 * - Field staff: read Active surveys only.
 * - Admins: full read/write/soft-delete.
 */

const { prisma } = require('../config/db');

// ── Helpers ────────────────────────────────────────────────────────────────

const isAdmin = (req) => req.user?.role === 'Admin';

// ── @route   GET /api/surveys
// ── @access  Private (FieldStaff sees Active only; Admin sees all)
exports.getSurveys = async (req, res) => {
    try {
        const where = { isDeleted: false };

        if (!isAdmin(req)) {
            where.status = 'Active';
        }

        const surveys = await prisma.survey.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            include: {
                category: { select: { id: true, name: true } },
                createdBy: { select: { id: true, username: true } },
                _count: { select: { responses: true } },
            },
        });

        res.json({ count: surveys.length, surveys });
    } catch (error) {
        console.error('[getSurveys]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   GET /api/surveys/:id
// ── @access  Private
exports.getSurveyById = async (req, res) => {
    try {
        const where = { id: req.params.id, isDeleted: false };

        // FieldStaff may only fetch Active surveys
        if (!isAdmin(req)) {
            where.status = 'Active';
        }

        const survey = await prisma.survey.findFirst({
            where,
            include: {
                category: true,
                createdBy: { select: { id: true, username: true } },
            },
        });

        if (!survey) {
            return res.status(404).json({ message: 'Survey not found' });
        }

        res.json(survey);
    } catch (error) {
        console.error('[getSurveyById]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   POST /api/surveys
// ── @access  Private – Admin only
exports.createSurvey = async (req, res) => {
    if (!isAdmin(req)) {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    const { title, description, status, categoryId, questions } = req.body;

    if (!title) {
        return res.status(400).json({ message: 'Title is required' });
    }

    try {
        const survey = await prisma.survey.create({
            data: {
                title,
                description: description || null,
                status: status || 'Draft',
                categoryId: categoryId || null,
                questions: questions || [],
                createdById: req.user.id,
            },
            include: {
                category: { select: { id: true, name: true } },
                createdBy: { select: { id: true, username: true } },
            },
        });

        res.status(201).json(survey);
    } catch (error) {
        console.error('[createSurvey]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   PUT /api/surveys/:id
// ── @access  Private – Admin only
exports.updateSurvey = async (req, res) => {
    if (!isAdmin(req)) {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    const { title, description, status, categoryId, questions } = req.body;

    try {
        const existing = await prisma.survey.findFirst({
            where: { id: req.params.id, isDeleted: false },
        });

        if (!existing) {
            return res.status(404).json({ message: 'Survey not found' });
        }

        const survey = await prisma.survey.update({
            where: { id: req.params.id },
            data: {
                ...(title !== undefined && { title }),
                ...(description !== undefined && { description }),
                ...(status !== undefined && { status }),
                ...(categoryId !== undefined && { categoryId }),
                ...(questions !== undefined && { questions }),
            },
            include: {
                category: { select: { id: true, name: true } },
                createdBy: { select: { id: true, username: true } },
            },
        });

        res.json(survey);
    } catch (error) {
        console.error('[updateSurvey]', error);
        res.status(500).json({ message: error.message });
    }
};

// ── @route   DELETE /api/surveys/:id
// ── @access  Private – Admin only (soft delete)
exports.deleteSurvey = async (req, res) => {
    if (!isAdmin(req)) {
        return res.status(403).json({ message: 'Forbidden: Admins only' });
    }

    try {
        const existing = await prisma.survey.findFirst({
            where: { id: req.params.id, isDeleted: false },
        });

        if (!existing) {
            return res.status(404).json({ message: 'Survey not found' });
        }

        await prisma.survey.update({
            where: { id: req.params.id },
            data: { isDeleted: true, status: 'Closed' },
        });

        res.json({ message: 'Survey deleted successfully' });
    } catch (error) {
        console.error('[deleteSurvey]', error);
        res.status(500).json({ message: error.message });
    }
};
