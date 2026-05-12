const mongoose = require('mongoose');

// User schema for Admin and Field Staff
const userSchema = new mongoose.Schema({
    // TODO: Define user fields (username, email, passwordHash, role, isActive, etc.)
    username: {
        type: String,
        required: true,
        unique: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    // The role will determine access level (Admin vs FieldStaff)
    role: {
        type: String,
        enum: ['Admin', 'FieldStaff'],
        default: 'FieldStaff'
    }
    // Add passwordHash and other auth-related fields here in the future
}, {
    timestamps: true
});

module.exports = mongoose.model('User', userSchema);
