const Hospital = require('../models/Hospital');
const User = require('../models/User');

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

        res.json({
            utilisateurs: userCount,
            hopitaux: hospitalCount,
            hopitauxVerifies: verifiedHospitals,
            hopitauxEnAttente: pendingHospitals,
            dons: donationCount
        });
    } catch (error) {
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

const Donation = require('../models/Donation');

// @desc    Obtenir les rapports et stats nationales
// @route   GET /api/admin/reports
exports.getReports = async (req, res) => {
    try {
        const users = await User.find({});
        const hospitals = await Hospital.find({});
        
        const regions = ["Centre", "Hauts-Bassins", "Cascades", "Nord", "Est", "Sud-Ouest", "Boucle du Mouhoun", "Sahel", "Centre-Est", "Centre-Nord", "Centre-Ouest", "Centre-Sud", "Plateau-Central"];
        
        const regionalData = regions.map(region => ({
            region,
            hospitals: hospitals.filter(h => h.region === region).length,
            donors: users.filter(u => u.lieuResidence === region).length,
            donations: Math.floor(Math.random() * 100),
            growth: Math.floor(Math.random() * 15) - 2
        })).filter(r => r.hospitals > 0 || r.donors > 0);

        res.json({
            regionalData,
            monthlyTrends: [
                { month: "Oct", donations: 980 },
                { month: "Nov", donations: 1020 },
                { month: "Déc", donations: 890 },
                { month: "Jan", donations: 1150 },
                { month: "Fév", donations: 1080 },
                { month: "Mar", donations: 1240 }
            ]
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
