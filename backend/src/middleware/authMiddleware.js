const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Hospital = require('../models/Hospital');
const Admin = require('../models/Admin');

const protect = async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];
            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            req.user = await Admin.findById(decoded.id).select('-motDePasse') ||
                await User.findById(decoded.id).select('-motDePasse') ||
                await Hospital.findById(decoded.id).select('-motDePasse');

            if (!req.user) {
                return res.status(401).json({ message: 'Non autorisé, utilisateur inconnu' });
            }

            next();
        } catch (error) {
            console.error(error);
            res.status(401).json({ message: 'Token invalide' });
        }
    }

    if (!token) {
        res.status(401).json({ message: 'Non autorisé, jéton absent' });
    }
};

module.exports = { protect };
