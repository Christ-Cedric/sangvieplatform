const Hospital = require('../models/Hospital');
const User = require('../models/User');
const Donation = require('../models/Donation');
const Notification = require('../models/Notification');
const BloodRequest = require('../models/BloodRequest');

// @desc    Valider un compte d'hôpital
// @route   PUT /api/admin/verify-hospital/:id
exports.verifyHospital = async (req, res) => {
    try {
        const hospital = await Hospital.findById(req.params.id);
        if (!hospital) return res.status(404).json({ message: 'Hôpital non trouvé' });

        hospital.verified = true;
        await hospital.save();
        res.json({ message: 'Compte hôpital validé avec succès' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Suspendre un compte (Utilisateur ou Hôpital)
// @route   PUT /api/admin/suspend/:id?type=User|Hospital
exports.suspendAccount = async (req, res) => {
    try {
        const { type } = req.query;
        let model = type === 'Hospital' ? Hospital : User;

        const account = await model.findById(req.params.id);
        if (!account) return res.status(404).json({ message: 'Compte non trouvé' });

        account.status = account.status === 'suspended' ? 'active' : 'suspended';
        await account.save();

        res.json({ 
            message: `Compte ${account.status === 'suspended' ? 'suspendu' : 'activé'} avec succès`,
            status: account.status 
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Supprimer un compte (Utilisateur ou Hôpital)
// @route   DELETE /api/admin/account/:id?type=User|Hospital
exports.deleteAccount = async (req, res) => {
    try {
        const { type } = req.query;
        let model = type === 'Hospital' ? Hospital : User;

        const deleted = await model.findByIdAndDelete(req.params.id);
        if (!deleted) return res.status(404).json({ message: 'Compte non trouvé' });

        res.json({ message: 'Compte supprimé avec succès' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Récupérer les hôpitaux en attente de validation
// @route   GET /api/admin/pending-hospitals
exports.getPendingHospitals = async (req, res) => {
    try {
        const hospitals = await Hospital.find({ verified: false }).select('-motDePasse');
        res.json(hospitals);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Récupérer tous les hôpitaux
// @route   GET /api/admin/hospitals
exports.getAllHospitals = async (req, res) => {
    try {
        const hospitals = await Hospital.find({}).select('-motDePasse');
        res.json(hospitals);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Obtenir des statistiques globales
// @route   GET /api/admin/stats
exports.getStats = async (req, res) => {
    try {
        const userCount = await User.countDocuments();
        const hospitalCount = await Hospital.countDocuments();
        const verifiedHospitals = await Hospital.countDocuments({ verified: true });
        const pendingHospitals = await Hospital.countDocuments({ verified: false });

        const donationCount = await Donation.countDocuments();
        
        // Calcul satisfaction
        const totalReq = await BloodRequest.countDocuments();
        const satisfiedReq = await BloodRequest.countDocuments({ statut: 'satisfait' });
        const satisfactionRate = totalReq > 0 ? Math.round((satisfiedReq / totalReq) * 100) : 100;

        // --- RÉCUPÉRATION DES ACTIVITÉS RÉCENTES ---
        console.log("DEBUG: Fetching recent activities...");
        const [recentRequests, recentDonations, recentUsers, recentHospitals] = await Promise.all([
            BloodRequest.find().sort({ createdAt: -1 }).limit(10).populate('hospitalId', 'nom'),
            Donation.find().sort({ createdAt: -1 }).limit(10).populate('userId', 'nom prenom').populate('hospitalId', 'nom'),
            User.find().sort({ createdAt: -1 }).limit(10),
            Hospital.find().sort({ createdAt: -1 }).limit(10)
        ]);

        console.log(`DEBUG COUNTS: Requests: ${recentRequests.length}, Donations: ${recentDonations.length}, Users: ${recentUsers.length}, Hospitals: ${recentHospitals.length}`);

        const activities = [];

        // 1. Demandes de sang
        recentRequests.forEach(req => {
            activities.push({
                date: req.createdAt || Date.now(),
                text: `Nouvelle demande ${req.groupeSanguin || '?'} (${req.niveauUrgence || 'Normal'})`,
                entity: req.hospitalId?.nom || "Hôpital",
                type: req.niveauUrgence === 'critique' ? 'alert' : 'info'
            });
        });

        // 2. Dons / Réponses
        recentDonations.forEach(don => {
            const userName = don.userId ? `${don.userId.prenom} ${don.userId.nom}` : "Utilisateur";
            if (don.statut === 'complete') {
                activities.push({
                    date: don.createdAt || Date.now(),
                    text: `Don de sang confirmé (${don.groupeSanguin || '?'})`,
                    entity: userName,
                    type: 'success'
                });
            } else {
                activities.push({
                    date: don.createdAt || Date.now(),
                    text: `Réponse à une demande (${don.groupeSanguin || '?'})`,
                    entity: userName,
                    type: 'info'
                });
            }
        });

        // 3. Nouveaux Utilisateurs
        recentUsers.forEach(u => {
            activities.push({
                date: u.createdAt || Date.now(),
                text: "Nouvelle inscription (Donneur)",
                entity: `${u.prenom || ''} ${u.nom || ''}`.trim() || "Utilisateur anonyme",
                type: 'info'
            });
        });

        // 4. Hôpitaux (Inscriptions et Validations)
        recentHospitals.forEach(h => {
          if (!h.verified) {
            activities.push({
              date: h.createdAt || Date.now(),
              text: "Nouveau compte en attente",
              entity: h.nom || "Institution",
              type: 'info'
            });
          } else {
            // Un hôpital vérifié récemment est une action admin
            activities.push({
              date: h.updatedAt || h.createdAt,
              text: "Compte institutionnel validé",
              entity: h.nom || "Institution",
              type: 'success'
            });
          }
        });

        console.log(`DEBUG: Found ${activities.length} total activity items (including admin actions).`);

        // Trier par date décroissante
        const sortedActivities = activities
            .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
            .slice(0, 15);

        res.json({
            utilisateurs: userCount,
            hopitaux: hospitalCount,
            hopitauxVerifies: verifiedHospitals,
            hopitauxEnAttente: pendingHospitals,
            dons: donationCount,
            satisfaction: satisfactionRate,
            recentActivities: sortedActivities
        });
    } catch (error) {
        console.error("DEBUG ERROR in getStats:", error);
        res.status(500).json({ message: error.message });
    }
};

// @desc    Récupérer tous les utilisateurs (donneurs)
// @route   GET /api/admin/users
exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.find({}).select('-motDePasse');
        res.json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Obtenir les rapports et stats nationales
// @route   GET /api/admin/reports
exports.getReports = async (req, res) => {
    try {
        const users = await User.find({});
        const hospitals = await Hospital.find({});
        const donations = await Donation.find({});
        const requests = await BloodRequest.find({});
        
        const regions = ["Bankui", "Djôrô", "Goulmou", "Guiriko", "Kadiogo", "Kuilsé", "Liptako", "Nando", "Nakambé", "Nazinon", "Oubri", "Sirba", "Soum", "Sourou", "Tannounyan", "Tapoa", "Yaadga"];
        
        const regionalData = regions.map(region => {
            const regionHospitals = hospitals.filter(h => h.region === region);
            const hospitalIds = regionHospitals.map(h => h._id.toString());
            
            // Pour les donneurs, on cherche si la région est inclue dans leur lieu de résidence
            const regionDonors = users.filter(u => u.lieuResidence && u.lieuResidence.includes(region)).length;
            
            // Pour les dons, on compte ceux faits dans les hôpitaux de cette région
            const regionDonations = donations.filter(d => d.hospitalId && hospitalIds.includes(d.hospitalId.toString())).length;
            
            // Calcul de croissance (basée sur l'activité récente vs historique ou par défaut 0)
            const growth = regionDonors > 0 ? (Math.min(25, (regionDonations / regionDonors) * 10)).toFixed(1) : 0;

            return {
                region,
                hospitals: regionHospitals.length,
                donors: regionDonors,
                donations: regionDonations,
                growth: parseFloat(growth)
            };
        });

        // Calcul des tendances mensuelles réelles sur les 6 derniers mois
        const monthlyTrends = [];
        const now = new Date();
        
        for (let i = 5; i >= 0; i--) {
            const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
            const monthLabel = d.toLocaleString('fr-FR', { month: 'short' });
            
            const count = donations.filter(don => {
                const donDate = new Date(don.dateDon);
                return donDate.getMonth() === d.getMonth() && donDate.getFullYear() === d.getFullYear();
            }).length;
            
            monthlyTrends.push({ 
                month: monthLabel.charAt(0).toUpperCase() + monthLabel.slice(1).replace('.', ''), 
                donations: count 
            });
        }

        // Calcul de croissance globale (ce mois vs mois dernier)
        const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
        const thisMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        const currentMonthDonations = donations.filter(d => new Date(d.dateDon) >= thisMonth).length;
        const lastMonthDonations = donations.filter(d => {
            const date = new Date(d.dateDon);
            return date >= lastMonth && date < thisMonth;
        }).length;
        const donationGrowth = lastMonthDonations > 0 ? ((currentMonthDonations - lastMonthDonations) / lastMonthDonations * 100).toFixed(1) : (currentMonthDonations > 0 ? 100 : 0);

        const currentMonthUsers = users.filter(u => new Date(u.createdAt) >= thisMonth).length;
        const lastMonthUsers = users.filter(u => {
            const date = new Date(u.createdAt);
            return date >= lastMonth && date < thisMonth;
        }).length;
        const donorGrowth = lastMonthUsers > 0 ? ((currentMonthUsers - lastMonthUsers) / lastMonthUsers * 100).toFixed(1) : (currentMonthUsers > 0 ? 100 : 0);

        const currentMonthHospitals = hospitals.filter(h => new Date(h.createdAt) >= thisMonth).length;
        const lastMonthHospitals = hospitals.filter(h => {
            const date = new Date(h.createdAt);
            return date >= lastMonth && date < thisMonth;
        }).length;
        const hospitalGrowth = lastMonthHospitals > 0 ? ((currentMonthHospitals - lastMonthHospitals) / lastMonthHospitals * 100).toFixed(1) : (currentMonthHospitals > 0 ? 100 : 0);

        // Taux de satisfaction global
        const satisfiedCount = requests.filter(r => r.statut === 'satisfait').length;
        const totalRequests = requests.length;
        const satisfactionRate = totalRequests > 0 ? Math.round((satisfiedCount / totalRequests) * 100) : 100;

        const activeDonorsCount = users.filter(u => u.statutDonneur === 'actif').length;

        res.json({
            regionalData,
            monthlyTrends,
            satisfactionRate,
            activeDonorsCount,
            currentMonthDonations,
            growth: {
                donations: parseFloat(donationGrowth),
                donors: parseFloat(donorGrowth),
                hospitals: parseFloat(hospitalGrowth)
            }
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Consulter les notifications de l'admin
// @route   GET /api/admin/notifications
exports.getNotifications = async (req, res) => {
    try {
        const notifications = await Notification.find({ 
            destinataire: req.user._id,
            typeDestinataire: 'Admin'
        }).sort({ createdAt: -1 });
        res.json(notifications);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Marquer toutes les notifications comme lues
// @route   PUT /api/admin/notifications/read
exports.markNotificationsAsRead = async (req, res) => {
    try {
        await Notification.updateMany(
            { destinataire: req.user._id, typeDestinataire: 'Admin', lue: false },
            { lue: true }
        );
        res.json({ message: "Notifications marquées comme lues" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
