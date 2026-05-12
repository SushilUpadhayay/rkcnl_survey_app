const mongoose = require('mongoose');

// Sub-document schema for Questions to be embedded within Surveys
const questionSchema = new mongoose.Schema({
    type: {
        type: String,
        enum: [
            'MultiChoiceMultiSelect', 
            'MultiChoiceSingleSelect', 
            'ChoiceWithAddition', 
            'ChoiceWithFreeWriting', 
            'OpenEnd', 
            'Ranking', 
            'PickingUp', 
            'PickupAndRank', 
            'RatingScale', 
            'Matrix'
        ],
        required: true
    },
    text: {
        type: String,
        required: true
    },
    // Options can be a mixed array to support complex question types
    options: [],
    isRequired: {
        type: Boolean,
        default: false
    }
});

// Main Survey schema
const surveySchema = new mongoose.Schema({
    title: {
        type: String,
        required: true
    },
    description: String,
    category: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Category'
    },
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    },
    status: {
        type: String,
        enum: ['Draft', 'Active', 'Closed'],
        default: 'Draft'
    },
    isDeleted: {
        type: Boolean,
        default: false // Supports soft deletion
    },
    questions: [questionSchema]
}, {
    timestamps: true
});

module.exports = mongoose.model('Survey', surveySchema);
