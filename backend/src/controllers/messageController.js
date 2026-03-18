const Message = require('../models/Message');
const Notification = require('../models/Notification');
const Donation = require('../models/Donation');
const User = require('../models/User');
const Hospital = require('../models/Hospital');

// @desc    Envoyer un message
// @route   POST /api/messages
exports.sendMessage = async (req, res) => {
    try {
        const { receiverId, receiverType, content, donationId, requestId } = req.body;
        
        // Determiner le type d'expediteur
        let senderType = 'User';
        if (req.user.role === 'hospital') {
            senderType = 'Hospital';
        } else if (req.user.role === 'admin') {
            senderType = 'User'; // Par defaut si admin
        }

        const message = await Message.create({
            senderId: req.user._id,
            senderType,
            receiverId,
            receiverType,
            content,
            donationId,
            requestId
        });

        // Creer une notification pour le destinataire
        await Notification.create({
            destinataire: receiverId,
            typeDestinataire: receiverType,
            message: `Nouveau message de ${req.user.nom}: ${content.substring(0, 30)}...`,
            type: 'systeme' // On peut ajouter un type 'message' plus tard
        });

        res.status(201).json(message);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Obtenir les messages d'une conversation
// @route   GET /api/messages/:otherId
exports.getConversationMessages = async (req, res) => {
    try {
        const { otherId } = req.params;
        const myId = req.user._id;

        const messages = await Message.find({
            $or: [
                { senderId: myId, receiverId: otherId },
                { senderId: otherId, receiverId: myId }
            ]
        }).sort({ createdAt: 1 });

        // Marquer les messages recus comme lus
        await Message.updateMany(
            { receiverId: myId, senderId: otherId, isRead: false },
            { isRead: true }
        );

        res.json(messages);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Lister les conversations
// @route   GET /api/messages/conversations
exports.getConversations = async (req, res) => {
    try {
        const myId = req.user._id;

        const messages = await Message.find({
            $or: [{ senderId: myId }, { receiverId: myId }]
        }).sort({ createdAt: -1 });

        const conversations = [];
        const seenIds = new Set();

        for (const msg of messages) {
            const otherId = msg.senderId.toString() === myId.toString() ? msg.receiverId : msg.senderId;
            const otherType = msg.senderId.toString() === myId.toString() ? msg.receiverType : msg.senderType;

            if (!seenIds.has(otherId.toString())) {
                seenIds.add(otherId.toString());
                
                let name = otherType === 'Hospital' ? 'Hôpital' : 'Donneur';
                try {
                    if (otherType === 'Hospital') {
                        const h = await Hospital.findById(otherId).select('nom');
                        if (h) name = h.nom;
                    } else {
                        const u = await User.findById(otherId).select('nom prenom');
                        if (u) name = `${u.prenom} ${u.nom}`;
                    }
                } catch (e) {
                    console.error("Error fetching name for conversation", e);
                }

                conversations.push({
                    otherId,
                    otherType,
                    otherName: name,
                    lastMessage: msg.content,
                    date: msg.createdAt,
                    isRead: msg.receiverId.toString() === myId.toString() ? msg.isRead : true
                });
            }
        }

        res.json(conversations);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
