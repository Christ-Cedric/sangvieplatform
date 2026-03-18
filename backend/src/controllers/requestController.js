const BloodRequest = require('../models/BloodRequest');

// @desc    Obtenir toutes les demandes de sang (Fil d'actualité)
// @route   GET /api/requests
exports.getAllRequests = async (req, res) => {
    try {
        const requests = await BloodRequest.find({ statut: 'en_attente' })
            .populate('hospitalId', 'nom region localisation')
            .sort({ createdAt: -1 });
        res.json(requests);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
