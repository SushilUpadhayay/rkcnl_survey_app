const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
    govId: {
        type: String,
        required: [true, 'Government ID is required'],
        unique: true,
        trim: true
    },
    password: {
        type: String,
        required: [true, 'Security token is required'],
        minlength: 6
    },
    role: {
        type: String,
        enum: ['admin', 'field_staff', 'analyst'],
        default: 'field_staff'
    },
    name: {
        type: String,
        required: true
    },
    lastLogin: {
        type: Date
    },
    status: {
        type: String,
        enum: ['active', 'suspended', 'revoked'],
        default: 'active'
    }
}, {
    timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function(next) {
    if (!this.isModified('password')) return next();
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
});

// Match password
userSchema.methods.matchPassword = async function(enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
