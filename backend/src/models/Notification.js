const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    destinataire: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        refPath: 'typeDestinataire'
    },
    typeDestinataire: {
        type: String,
        required: true,
        enum: ['User', 'Hospital']
    },
    message: { type: String, required: true },
    dateHeure: { type: Date, default: Date.now },
    lue: { type: Boolean, default: false },
    type: {
        type: String,
        enum: ['demande_urgence', 'rappel_don', 'don_valide', 'presence_confirmee', 'reponse_demande', 'systeme'],
        default: 'systeme'
    }
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);
