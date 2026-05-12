const mongoose = require('mongoose');

const surveySchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    district: {
        type: String,
        required: true
    },
    cropType: {
        type: String,
        required: true
    },
    landArea: {
        type: Number,
        required: true
    },
    healthStatus: {
        type: String,
        enum: ['Optimal', 'Good', 'Stressed', 'Critical'],
        default: 'Good'
    },
    notes: {
        type: String
    },
    location: {
        type: {
            type: String,
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [longitude, latitude]
            index: '2dsphere'
        }
    },
    images: [String],
    syncId: {
        type: String,
        unique: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Survey', surveySchema);
