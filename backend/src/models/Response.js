const mongoose = require('mongoose');

// Response schema to store submitted surveys
// Supports offline-sync by utilizing deviceTimestamp and potential custom fields
const responseSchema = new mongoose.Schema({
    survey: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Survey',
        required: true
    },
    submittedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    // deviceTimestamp allows chronological ordering of responses collected offline
    deviceTimestamp: {
        type: Date,
        required: true
    },
    // Structure to hold varying answer types based on question ID
    answers: [{
        questionId: {
            type: mongoose.Schema.Types.ObjectId,
            required: true
        },
        answerValue: mongoose.Schema.Types.Mixed
    }],
    // Field staff can add general notes to a specific survey run
    personalNotes: {
        type: String
    },
    // Custom questions added during this specific field survey run
    customQuestions: [{
        text: String,
        answerValue: mongoose.Schema.Types.Mixed
    }]
}, {
    timestamps: true
});

module.exports = mongoose.model('Response', responseSchema);
