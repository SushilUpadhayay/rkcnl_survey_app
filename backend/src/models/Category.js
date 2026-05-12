const mongoose = require('mongoose');

// Category schema to group surveys logically
const categorySchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
        unique: true
    },
    description: {
        type: String
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Category', categorySchema);
