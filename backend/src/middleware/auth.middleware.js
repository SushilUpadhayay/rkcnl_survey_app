const jwt = require('jsonwebtoken');
const { prisma } = require('../config/db');

// @desc    Verify JWT and attach full user object (including role) to req.user
// @access  Private
const protect = async (req, res, next) => {
    let token;

    try {
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];

            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            // Fetch fresh user from DB — includes role for RBAC
            req.user = await prisma.user.findUnique({
                where: { id: decoded.id },
                select: {
                    id: true,
                    username: true,
                    email: true,
                    role: true,
                    isActive: true
                }
            });

            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: 'Not authorized, user not found'
                });
            }

            if (!req.user.isActive) {
                return res.status(401).json({
                    success: false,
                    message: 'Not authorized, account is inactive'
                });
            }

            next();
        } else {
            return res.status(401).json({
                success: false,
                message: 'Not authorized, no token provided'
            });
        }
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: 'Not authorized, token expired'
            });
        }
        return res.status(401).json({
            success: false,
            message: 'Not authorized, token invalid'
        });
    }
};

// @desc    Role-based authorization middleware factory
// @usage   router.get('/admin-only', protect, authorize('Admin'), handler)
// @access  Called after protect — req.user must be populated
const authorize = (...roles) => {
    return (req, res, next) => {
        if (!req.user || !roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: `Access denied. Requires one of these roles: ${roles.join(', ')}`
            });
        }
        next();
    };
};

module.exports = { protect, authorize };
