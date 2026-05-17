const { prisma } = require('../config/db');

// @desc    Create a new survey
// @route   POST /api/surveys
// @access  Private
const createSurvey = async (req, res) => {
    try {
        const { title, description, categoryId } = req.body;

        if (!title) {
            return res.status(400).json({
                success: false,
                message: 'Survey title is required'
            });
        }

        // req.user is attached by auth.middleware.js
        const survey = await prisma.survey.create({
            data: {
                title,
                description,
                categoryId: categoryId || null,
                createdById: req.user.id
            },
            include: {
                createdBy: {
                    select: { id: true, username: true, email: true }
                },
                category: {
                    select: { id: true, name: true }
                }
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

// @desc    Get all active surveys
// @route   GET /api/surveys
// @access  Public
const getAllSurveys = async (req, res) => {
    try {
        const surveys = await prisma.survey.findMany({
            where: { isDeleted: false },
            orderBy: { createdAt: 'desc' },
            include: {
                createdBy: {
                    select: { id: true, username: true }
                },
                category: {
                    select: { id: true, name: true }
                }
            }
        });

        res.status(200).json({
            success: true,
            count: surveys.length,
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
// @access  Public
const getSurveyById = async (req, res) => {
    try {
        const survey = await prisma.survey.findFirst({
            where: {
                id: req.params.id,
                isDeleted: false
            },
            include: {
                createdBy: {
                    select: { id: true, username: true, email: true }
                },
                category: {
                    select: { id: true, name: true }
                }
            }
        });

        if (!survey) {
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

// @desc    Get surveys assigned to the current user
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
                surveyId_userId: {
                    surveyId,
                    userId
                }
            }
        });

        if (existing) {
            return res.status(400).json({
                success: false,
                message: 'Survey is already assigned to this user'
            });
        }

        const assignment = await prisma.surveyAssignment.create({
            data: {
                surveyId,
                userId
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
                title: title || undefined,
                description: description || undefined,
                status: status || undefined,
                questions: questions || undefined,
                categoryId: categoryId || undefined
            },
            include: {
                category: { select: { id: true, name: true } }
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
    updateSurvey, 
    deleteSurvey 
};
