const { prisma } = require('../config/db');

// @desc    Create a new survey
// @route   POST /api/surveys
// @access  Private (Admin)
const createSurvey = async (req, res) => {
    try {
        const { title, description, status, questions, categoryId } = req.body;

        if (!title) {
            return res.status(400).json({
                success: false,
                message: 'Please provide a survey title'
            });
        }

        const survey = await prisma.survey.create({
            data: {
                title,
                description: description || null,
                status: status || 'Draft',
                questions: questions || [],
                categoryId: categoryId || null,
                createdById: req.user.id
            },
            include: {
                category: { select: { id: true, name: true } },
                createdBy: { select: { id: true, fullName: true } }
            }
        });

        res.status(201).json({
            success: true,
            message: 'Survey created successfully',
            data: survey
        });

    } catch (error) {
        console.error('Create survey error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while creating survey',
            error: error.message
        });
    }
};

// @desc    Get all non-deleted surveys (Admin view — all statuses)
// @route   GET /api/surveys
// @access  Private (Admin)
const getAllSurveys = async (req, res) => {
    try {
        const { status, categoryId, page = 1, limit = 10, search } = req.query;

        const where = { isDeleted: false };
        if (status) where.status = status;
        if (categoryId) where.categoryId = categoryId;
        if (search) {
            where.title = { contains: search, mode: 'insensitive' };
        }

        const skip = (parseInt(page) - 1) * parseInt(limit);
        const take = parseInt(limit);

        const [surveys, total] = await Promise.all([
            prisma.survey.findMany({
                where,
                include: {
                    category: { select: { id: true, name: true } },
                    createdBy: { select: { id: true, fullName: true } },
                    _count: {
                        select: { responses: true, assignments: true }
                    }
                },
                orderBy: { createdAt: 'desc' },
                skip,
                take
            }),
            prisma.survey.count({ where })
        ]);

        res.status(200).json({
            success: true,
            count: surveys.length,
            total,
            page: parseInt(page),
            totalPages: Math.ceil(total / take),
            data: surveys
        });

    } catch (error) {
        console.error('Get all surveys error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching surveys',
            error: error.message
        });
    }
};

// @desc    Get a single survey by ID
// @route   GET /api/surveys/:id
// @access  Private (Admin)
const getSurveyById = async (req, res) => {
    try {
        const survey = await prisma.survey.findUnique({
            where: { id: req.params.id },
            include: {
                category: { select: { id: true, name: true } },
                createdBy: { select: { id: true, fullName: true } },
                _count: {
                    select: { responses: true, assignments: true }
                }
            }
        });

        if (!survey || survey.isDeleted) {
            return res.status(404).json({
                success: false,
                message: 'Survey not found'
            });
        }

        res.status(200).json({
            success: true,
            data: survey
        });

    } catch (error) {
        console.error('Get survey by ID error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching survey',
            error: error.message
        });
    }
};

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

// @desc    Assign a survey to a user
// @route   POST /api/surveys/assign
// @access  Private (Admin)
const assignSurvey = async (req, res) => {
    try {
        const { surveyId, userId } = req.body;

        if (!surveyId || !userId) {
            return res.status(400).json({
                success: false,
                message: 'Please provide surveyId and userId'
            });
        }

        // Check if assignment already exists
        const existing = await prisma.surveyAssignment.findUnique({
            where: {
                surveyId_userId: { surveyId, userId }
            }
        });

        if (existing) {
            return res.status(409).json({
                success: false,
                message: 'Survey is already assigned to this user'
            });
        }

        const assignment = await prisma.surveyAssignment.create({
            data: { surveyId, userId },
            include: {
                survey: { select: { id: true, title: true } },
                user: { select: { id: true, fullName: true, email: true } }
            }
        });

        res.status(201).json({
            success: true,
            message: 'Survey assigned successfully',
            data: assignment
        });

    } catch (error) {
        console.error('Assign survey error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while assigning survey',
            error: error.message
        });
    }
};

// @desc    Unassign a survey from a user
// @route   DELETE /api/surveys/assign
// @access  Private (Admin)
const unassignSurvey = async (req, res) => {
    try {
        const { surveyId, userId } = req.body;

        if (!surveyId || !userId) {
            return res.status(400).json({
                success: false,
                message: 'Please provide surveyId and userId'
            });
        }

        const existing = await prisma.surveyAssignment.findUnique({
            where: { surveyId_userId: { surveyId, userId } }
        });

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: 'Assignment not found'
            });
        }

        await prisma.surveyAssignment.delete({
            where: { surveyId_userId: { surveyId, userId } }
        });

        res.status(200).json({
            success: true,
            message: 'Survey unassigned successfully'
        });

    } catch (error) {
        console.error('Unassign survey error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while unassigning survey',
            error: error.message
        });
    }
};

// @desc    Get all assignments (optionally filtered by surveyId or userId)
// @route   GET /api/surveys/assignments
// @access  Private (Admin)
const getAssignments = async (req, res) => {
    try {
        const { surveyId, userId } = req.query;
        const where = {};
        if (surveyId) where.surveyId = surveyId;
        if (userId) where.userId = userId;

        const assignments = await prisma.surveyAssignment.findMany({
            where,
            include: {
                survey: { select: { id: true, title: true, status: true } },
                user: { select: { id: true, fullName: true, email: true } }
            },
            orderBy: { createdAt: 'desc' }
        });

        res.status(200).json({
            success: true,
            count: assignments.length,
            data: assignments
        });

    } catch (error) {
        console.error('Get assignments error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while fetching assignments',
            error: error.message
        });
    }
};

// @desc    Update a survey
// @route   PUT /api/surveys/:id
// @access  Private (Admin)
const updateSurvey = async (req, res) => {
    try {
        const { title, description, status, questions, categoryId } = req.body;

        let survey = await prisma.survey.findUnique({
            where: { id: req.params.id }
        });

        if (!survey || survey.isDeleted) {
            return res.status(404).json({
                success: false,
                message: 'Survey not found'
            });
        }

        survey = await prisma.survey.update({
            where: { id: req.params.id },
            data: {
                title: title ?? undefined,
                description: description ?? undefined,
                status: status ?? undefined,
                questions: questions ?? undefined,
                categoryId: categoryId ?? undefined,
                updatedById: req.user.id
            },
            include: {
                category: { select: { id: true, name: true } },
                createdBy: { select: { id: true, fullName: true } },
                updatedBy: { select: { id: true, fullName: true } }
            }
        });

        res.status(200).json({
            success: true,
            message: 'Survey updated successfully',
            data: survey
        });

    } catch (error) {
        console.error('Update survey error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while updating survey',
            error: error.message
        });
    }
};

// @desc    Soft delete a survey
// @route   DELETE /api/surveys/:id
// @access  Private (Admin)
const deleteSurvey = async (req, res) => {
    try {
        const survey = await prisma.survey.findUnique({
            where: { id: req.params.id }
        });

        if (!survey || survey.isDeleted) {
            return res.status(404).json({
                success: false,
                message: 'Survey not found'
            });
        }

        await prisma.survey.update({
            where: { id: req.params.id },
            data: { isDeleted: true }
        });

        res.status(200).json({
            success: true,
            message: 'Survey deleted successfully'
        });

    } catch (error) {
        console.error('Delete survey error:', error.message);
        res.status(500).json({
            success: false,
            message: 'Server error while deleting survey',
            error: error.message
        });
    }
};

module.exports = {
    createSurvey,
    getAllSurveys,
    getSurveyById,
    getAssignedSurveys,
    assignSurvey,
    unassignSurvey,
    getAssignments,
    updateSurvey,
    deleteSurvey
};
