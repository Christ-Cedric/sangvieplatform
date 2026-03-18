const mongoose = require('mongoose');

const donationSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    hospitalId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Hospital'
    },
    requestId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'BloodRequest'
    },
    groupeSanguin: { type: String, required: true },
    quantitePoches: { type: Number, required: true },
    dateDon: { type: Date, default: Date.now },
    lieuDon: { type: String, required: true },
    statut: {
        type: String,
        enum: ['prevu', 'complete', 'annule'],
        default: 'complete'
    }
}, { timestamps: true });

module.exports = mongoose.model('Donation', donationSchema);
