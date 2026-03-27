const BloodRequest = require('../models/BloodRequest');
const Notification = require('../models/Notification');
const User = require('../models/User');
const Hospital = require('../models/Hospital');
const Donation = require('../models/Donation');

// @desc    Soumettre une demande urgente
// @route   POST /api/hospitals/request
exports.createRequest = async (req, res) => {
    try {
        console.log('--- DEBUG CREATE REQUEST ---');
        console.log('User:', req.user);
        console.log('Body:', req.body);
        const { groupeSanguin, quantitePoches, niveauUrgence, description } = req.body;

        const request = await BloodRequest.create({
            hospitalId: req.user._id,
            groupeSanguin,
            quantitePoches,
            niveauUrgence,
            description
        });

        console.log('Request created:', request._id);

        // Simuler l'envoi de notification aux donneurs du même groupe
        const potentialDonors = await User.find({ groupeSanguin, statutDonneur: 'actif' });
        console.log(`Found ${potentialDonors.length} potential donors`);

        for (let donor of potentialDonors) {
            await Notification.create({
                destinataire: donor._id,
                typeDestinataire: 'User',
                message: `URGENT: Besoin de sang ${groupeSanguin} à l'Hôpital ${req.user.nom}`,
                type: 'demande_urgence'
            });
        }

        res.status(201).json(request);
    } catch (error) {
        console.error('ERROR IN createRequest:', error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Mettre à jour le profil de l'hôpital
// @route   PUT /api/hospitals/profile
exports.updateProfile = async (req, res) => {
    try {
        const { nom, contact, region, localisation } = req.body;
        const hospital = await Hospital.findById(req.user._id);

        if (nom) hospital.nom = nom;
        if (contact) hospital.contact = contact;
        if (region) hospital.region = region;
        if (localisation) hospital.localisation = localisation;

        await hospital.save();
        res.json({ message: "Profil mis à jour avec succès", hospital });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Confirmer qu'un don a été effectué
// @route   PUT /api/hospitals/confirm-donation/:donationId
exports.confirmDonation = async (req, res) => {
    try {
        const { donationId } = req.params;
        const donation = await Donation.findById(donationId);

        if (!donation) {
            return res.status(404).json({ message: "Don non trouvé" });
        }

        // Vérifier que c'est bien l'hôpital concerné
        if (donation.hospitalId.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: "Action non autorisée pour cet hôpital" });
        }

        // --- RÈGLE DES 3 MOIS (Sécurité hôpital) ---
        const lastDonation = await Donation.findOne({
            userId: donation.userId,
            statut: 'complete',
            _id: { $ne: donationId } // Ne pas compter le don actuel s'il était déjà marqué complete (cas bord)
        }).sort({ dateDon: -1 });

        if (lastDonation) {
            const threeMonthsInMs = 3 * 30 * 24 * 60 * 60 * 1000;
            const timeSinceLastDonation = Date.now() - new Date(lastDonation.dateDon).getTime();
            
            if (timeSinceLastDonation < threeMonthsInMs) {
                return res.status(400).json({ 
                    message: `Impossible de valider ce don. Le dernier don de ce donneur date de moins de 3 mois (${new Date(lastDonation.dateDon).toLocaleDateString('fr-FR')}).`
                });
            }
        }
        // -------------------------------------------

        donation.statut = 'complete';
        donation.dateDon = Date.now();
        await donation.save();

        // Notifier le donneur
        await Notification.create({
            destinataire: donation.userId,
            typeDestinataire: 'User',
            message: `Félicitations ! Votre don à l'Hôpital ${req.user.nom} a été validé. Vous avez sauvé des vies !`,
            type: 'don_valide'
        });

        res.json({ message: "Don confirmé avec succès", donation });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Consulter l'historique des demandes
// @route   GET /api/hospitals/my-requests
exports.getMyRequests = async (req, res) => {
    try {
        const requests = await BloodRequest.find({ hospitalId: req.user._id })
            .populate('hospitalId', 'nom region localisation')
            .sort({ createdAt: -1 });
        res.json(requests);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Consulter les statistiques de l'hôpital
// @route   GET /api/hospitals/stats
exports.getStats = async (req, res) => {
    try {
        const hospitalId = req.user._id;

        const totalRequests = await BloodRequest.countDocuments({ hospitalId });
        const confirmedDonationsCount = await Donation.countDocuments({ hospitalId, statut: 'complete' });
        const pendingDonationsCount = await Donation.countDocuments({ hospitalId, statut: 'en_attente' });
        
        // Trouver le nombre de donneurs uniques
        const uniqueDonors = await Donation.distinct('userId', { hospitalId, statut: 'complete' });

        // Distribution des groupes sanguins
        const confirmedDonations = await Donation.find({ hospitalId, statut: 'complete' }).populate('userId', 'groupeSanguin');
        
        const bloodGroups = {};
        confirmedDonations.forEach(d => {
            if (d.userId && d.userId.groupeSanguin) {
                bloodGroups[d.userId.groupeSanguin] = (bloodGroups[d.userId.groupeSanguin] || 0) + 1;
            }
        });

        const bloodGroupData = Object.keys(bloodGroups).map(group => ({
            group,
            count: bloodGroups[group],
            percentage: Math.round((bloodGroups[group] / confirmedDonationsCount) * 100)
        })).sort((a, b) => b.count - a.count);

        // Évolution mensuelle (6 derniers mois)
        const sixMonthsAgo = new Date();
        sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 5);
        sixMonthsAgo.setDate(1);

        const monthlyStats = await Donation.aggregate([
            {
                $match: {
                    hospitalId: req.user._id,
                    statut: 'complete',
                    dateDon: { $gte: sixMonthsAgo }
                }
            },
            {
                $group: {
                    _id: {
                        month: { $month: "$dateDon" },
                        year: { $year: "$dateDon" }
                    },
                    count: { $sum: 1 }
                }
            },
            { $sort: { "_id.year": 1, "_id.month": 1 } }
        ]);

        const monthNames = ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"];
        const monthlyData = [];
        
        for (let i = 0; i < 6; i++) {
            const d = new Date();
            d.setMonth(d.getMonth() - (5 - i));
            const monthIdx = d.getMonth();
            const year = d.getFullYear();
            
            const found = monthlyStats.find(s => s._id.month === (monthIdx + 1) && s._id.year === year);
            monthlyData.push({
                month: monthNames[monthIdx],
                donations: found ? found.count : 0
            });
        }

        // Activité récente
        const recentActivity = await Donation.find({ hospitalId })
            .populate('userId', 'nom prenom groupeSanguin')
            .sort({ createdAt: -1 })
            .limit(5);

        const activityLog = recentActivity.map(act => ({
            action: act.statut === 'complete' ? "Don confirmé" : "Nouvelle réponse",
            detail: `${act.userId?.prenom || ''} ${act.userId?.nom || 'Donneur'} · ${act.userId?.groupeSanguin || '?'}`,
            time: act.createdAt,
            dot: act.statut === 'complete' ? "bg-[#1A7A3F]" : "bg-[#CC0000]"
        }));

        res.json({
            totalRequests,
            confirmedDonations: confirmedDonationsCount,
            uniqueDonors: uniqueDonors.length,
            bloodGroupData,
            monthlyData,
            activityLog,
            responseRate: totalRequests > 0 ? Math.round(((confirmedDonationsCount + pendingDonationsCount) / totalRequests) * 100) : 0
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Obtenir les donneurs ayant répondu à une demande spécifique
// @route   GET /api/hospitals/request-responses/:requestId
exports.getRequestResponses = async (req, res) => {
    try {
        const { requestId } = req.params;
        const Message = require('../models/Message');
        const responses = await Donation.find({ requestId })
            .populate('userId', 'nom prenom telephone groupeSanguin')
            .sort({ createdAt: -1 });
        
        // Pour chaque réponse, on cherche s'il y a un message initial
        const responsesWithMessages = await Promise.all(responses.map(async (donation) => {
            const message = await Message.findOne({ donationId: donation._id, senderType: 'User' }).sort({ createdAt: 1 });
            return {
                ...donation.toObject(),
                message: message ? message.content : null
            };
        }));

        res.json(responsesWithMessages);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Consulter les notifications de l'hôpital
// @route   GET /api/hospitals/notifications
exports.getNotifications = async (req, res) => {
    try {
        const notifications = await Notification.find({ 
            destinataire: req.user._id,
            typeDestinataire: 'Hospital'
        }).sort({ createdAt: -1 });
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Marquer toutes les notifications comme lues
// @route   PUT /api/hospitals/notifications/read
exports.markNotificationsAsRead = async (req, res) => {
    try {
        await Notification.updateMany(
            { destinataire: req.user._id, typeDestinataire: 'Hospital', lue: false },
            { lue: true }
        );
        res.json({ message: "Notifications marquées comme lues" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Mettre à jour le statut d'une demande
// @route   PUT /api/hospitals/request/:requestId
exports.updateRequestStatus = async (req, res) => {
    try {
        const { requestId } = req.params;
        const { statut } = req.body;
        
        const request = await BloodRequest.findById(requestId);
        if (!request) return res.status(404).json({ message: "Demande non trouvée" });

        if (request.hospitalId.toString() !== req.user._id.toString()) {
            return res.status(403).json({ message: "Non autorisé" });
        }

        request.statut = statut;
        await request.save();
        res.json(request);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Récupérer tous les hôpitaux (public)
// @route   GET /api/hospitals
exports.getAllHospitalsPublic = async (req, res) => {
    try {
        const hospitals = await Hospital.find({}).select('-motDePasse');
        res.json(hospitals);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
