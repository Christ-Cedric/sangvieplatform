const User = require('../models/User');
const Donation = require('../models/Donation');
const BloodRequest = require('../models/BloodRequest');
const Notification = require('../models/Notification');

// @desc    Répondre à une demande de sang
// @route   POST /api/users/respond/:requestId
exports.respondToRequest = async (req, res) => {
    try {
        const { requestId } = req.params;
        const { message: initialMessage } = req.body;
        const request = await BloodRequest.findById(requestId);

        if (!request) {
            return res.status(404).json({ message: "Demande non trouvée" });
        }

        // --- RÈGLE DES 3 MOIS ---
        // Vérifier la date du dernier don complété
        const lastDonation = await Donation.findOne({
            userId: req.user._id,
            statut: 'complete'
        }).sort({ dateDon: -1 });

        if (lastDonation) {
            const threeMonthsInMs = 3 * 30 * 24 * 60 * 60 * 1000;
            const timeSinceLastDonation = Date.now() - new Date(lastDonation.dateDon).getTime();
            
            if (timeSinceLastDonation < threeMonthsInMs) {
                const nextEligibleDate = new Date(new Date(lastDonation.dateDon).getTime() + threeMonthsInMs);
                return res.status(400).json({ 
                    message: `Vous ne pouvez pas donner de sang pour le moment. Votre dernier don date du ${new Date(lastDonation.dateDon).toLocaleDateString('fr-FR')}. Vous serez éligible à nouveau le ${nextEligibleDate.toLocaleDateString('fr-FR')}.`,
                    nextEligibleDate
                });
            }
        }
        // ------------------------

        // Vérifier si l'utilisateur a déjà répondu à cette demande
        const existingDonation = await Donation.findOne({
            userId: req.user._id,
            requestId: request._id,
            statut: 'prevu'
        });

        if (existingDonation) {
            if (initialMessage) {
                const Message = require('../models/Message');
                await Message.create({
                    senderId: req.user._id,
                    senderType: 'User',
                    receiverId: request.hospitalId,
                    receiverType: 'Hospital',
                    requestId: request._id,
                    donationId: existingDonation._id,
                    content: initialMessage
                });
                return res.status(200).json({ message: "Message ajouté avec succès à votre réponse.", donation: existingDonation });
            }
            return res.status(400).json({ message: "Vous avez déjà répondu à cette demande. Veuillez vous rendre à l'hôpital." });
        }

        // Créer une intention de don (statut : prevu)
        const donation = await Donation.create({
            userId: req.user._id,
            hospitalId: request.hospitalId,
            requestId: request._id,
            groupeSanguin: request.groupeSanguin,
            quantitePoches: 1, // Par défaut 1 poche pour un don individuel
            lieuDon: 'Centre Hospitalier', // À affiner
            statut: 'prevu'
        });

        // Si un message initial est fourni, on le crée
        if (initialMessage) {
            const Message = require('../models/Message');
            await Message.create({
                senderId: req.user._id,
                senderType: 'User',
                receiverId: request.hospitalId,
                receiverType: 'Hospital',
                requestId: request._id,
                donationId: donation._id,
                content: initialMessage
            });
        }

        // Notifier l'hôpital
        await Notification.create({
            destinataire: request.hospitalId,
            typeDestinataire: 'Hospital',
            message: `Un donneur (${req.user.nom} ${req.user.prenom}) a répondu à votre demande de sang ${request.groupeSanguin}.${initialMessage ? ' (Message inclus)' : ''}`,
            type: 'reponse_demande'
        });

        res.status(201).json({ message: "Réponse enregistrée avec succès. Merci pour votre générosité !", donation });
    } catch (error) {
        console.error('ERROR IN respondToRequest:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Gérer le profil / Changer statut donneur
// @route   PUT /api/users/status
exports.updateDonorStatus = async (req, res) => {
    try {
        const { statutDonneur } = req.body;
        const user = await User.findById(req.user._id);

        user.statutDonneur = statutDonneur;
        await user.save();

        res.json({ message: `Votre statut est maintenant : ${statutDonneur}` });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Mettre à jour le profil utilisateur
// @route   PUT /api/users/profile
exports.updateProfile = async (req, res) => {
    try {
        const { nom, prenom, telephone, lieuResidence } = req.body;
        const user = await User.findById(req.user._id);

        if (nom) user.nom = nom;
        if (prenom) user.prenom = prenom;
        if (telephone) user.telephone = telephone;
        if (lieuResidence) user.lieuResidence = lieuResidence;

        await user.save();
        res.json({ message: "Profil mis à jour avec succès", user });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Consulter l'historique des dons
// @route   GET /api/users/my-donations
exports.getMyDonations = async (req, res) => {
    try {
        const donations = await Donation.find({ userId: req.user._id }).populate('hospitalId', 'nom');
        res.json(donations);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
