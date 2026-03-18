const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
    senderId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        refPath: 'senderType'
    },
    senderType: {
        type: String,
        required: true,
        enum: ['User', 'Hospital']
    },
    receiverId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        refPath: 'receiverType'
    },
    receiverType: {
        type: String,
        required: true,
        enum: ['User', 'Hospital']
    },
    requestId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'BloodRequest'
    },
    donationId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Donation'
    },
    content: {
        type: String,
        required: true
    },
    isRead: {
        type: Boolean,
        default: false
    }
}, { timestamps: true });

module.exports = mongoose.model('Message', messageSchema);
