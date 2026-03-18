const mongoose = require('mongoose');

const bloodRequestSchema = new mongoose.Schema({
    hospitalId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Hospital',
        required: true
    },
    groupeSanguin: {
        type: String,
        enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
        required: true
    },
    quantitePoches: { type: Number, required: true },
    niveauUrgence: {
        type: String,
        enum: ['normal', 'urgent', 'critique'],
        default: 'normal'
    },
    description: { type: String },
    dateDemande: { type: Date, default: Date.now },
    statut: {
        type: String,
        enum: ['en_attente', 'satisfait', 'annule'],
        default: 'en_attente'
    }
}, { timestamps: true });

module.exports = mongoose.model('BloodRequest', bloodRequestSchema);
