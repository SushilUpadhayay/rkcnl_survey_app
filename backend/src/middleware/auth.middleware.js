const jwt = require('jsonwebtoken');
const { prisma } = require('../config/db');

// @desc    Verify JWT and attach full user object to req.user
// @access  Private
const protect = async (req, res, next) => {
    let token;

    try {
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];

            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            // Fetch fresh user from DB to ensure they still exist and are active
            req.user = await prisma.user.findUnique({
                where: { id: decoded.id },
                select: {
                    id: true,
                    username: true,
                    email: true,
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

module.exports = { protect };
