const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Hospital = require('../models/Hospital');
const Admin = require('../models/Admin');

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: '30d' });
};

// @desc    S'inscrire en tant qu'utilisateur (donneur)
// @route   POST /api/auth/register-user
exports.registerUser = async (req, res) => {
    try {
        const { nom, prenom, email, motDePasse, telephone, lieuResidence, groupeSanguin } = req.body;

        const userExists = await User.findOne({ telephone });
        if (userExists) return res.status(400).json({ message: 'L\'utilisateur avec ce numéro existe déjà' });

        const user = await User.create({ nom, prenom, email, motDePasse, telephone, lieuResidence, groupeSanguin });

        res.status(201).json({
            _id: user._id, nom, prenom, email, telephone,
            token: generateToken(user._id)
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    S'inscrire en tant qu'hôpital
// @route   POST /api/auth/register-hospital
exports.registerHospital = async (req, res) => {
    try {
        const { nom, email, motDePasse, numeroAgrement, contact, region, localisation } = req.body;

        const hospitalExists = await Hospital.findOne({ contact });
        if (hospitalExists) return res.status(400).json({ message: 'L\'hôpital avec ce contact existe déjà' });

        const hospital = await Hospital.create({
            nom, email, motDePasse, numeroAgrement, contact, region, localisation
        });

        res.status(201).json({
            _id: hospital._id, nom, email, contact,
            token: generateToken(hospital._id)
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Connexion générale (Admin, Hôpital, Utilisateur)
// @route   POST /api/auth/login
exports.login = async (req, res) => {
    try {
        const { identifier, motDePasse, telephone, contact, nomUtilisateur } = req.body;
        
        // Support de l'ancien format (telephone/contact/nomUtilisateur) et du nouveau (identifier)
        const loginId = identifier || telephone || contact || nomUtilisateur;

        if (!loginId || !motDePasse) {
            return res.status(400).json({ message: 'Veuillez fournir un identifiant et un mot de passe' });
        }

        let identity;
        
        // 1. Chercher dans les Admins
        identity = await Admin.findOne({ 
            $or: [{ nomUtilisateur: loginId }, { email: loginId }] 
        });

        // 2. Si non trouvé, chercher dans les Utilisateurs
        if (!identity) {
            identity = await User.findOne({ 
                $or: [{ telephone: loginId }, { email: loginId }] 
            });
        }

        // 3. Si toujours non trouvé, chercher dans les Hôpitaux
        if (!identity) {
            identity = await Hospital.findOne({ 
                $or: [{ contact: loginId }, { email: loginId }] 
            });
        }

        if (identity && (await identity.matchPassword(motDePasse))) {
            // Vérification du statut pour les hôpitaux
            if (identity.role === 'hospital' && !identity.verified) {
                return res.status(401).json({ 
                    message: 'Votre compte est en attente de validation par l\'administrateur. Veuillez réessayer plus tard.' 
                });
            }

            // Retourner l'objet complet sans le mot de passe
            const userResponse = identity.toObject();
            delete userResponse.motDePasse;
            userResponse.token = generateToken(identity._id);

            res.json(userResponse);
        } else {
            res.status(401).json({ message: 'Identifiants invalides (Vérifiez votre identifiant et mot de passe)' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
