const express = require('express');
const router = express.Router();
<<<<<<< Updated upstream
const authController = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Define auth routes mapping to controller placeholders
router.post('/register', authController.register);
router.post('/login', authController.login);
router.get('/me', protect, authController.getMe);
=======
const { loginUser, registerUser } = require('../controllers/authController');

router.post('/login', loginUser);
router.post('/register', registerUser);
>>>>>>> Stashed changes

module.exports = router;
