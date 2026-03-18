const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Admin = require('./src/models/Admin');
const path = require('path');

// Charger les variables d'environnement
dotenv.config();

const createAdmin = async () => {
    try {
        // Connexion à MongoDB
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connecté à MongoDB...');

        // Vérifier si un admin existe déjà
        const adminExists = await Admin.findOne({ nomUtilisateur: 'admin' });

        if (adminExists) {
            console.log('L\'administrateur existe déjà.');
            process.exit(0);
        }

        // Création de l'admin
        const admin = new Admin({
            nomUtilisateur: 'admin',
            motDePasse: 'admin123' // Il sera haché automatiquement par le modèle Admin.js
        });

        await admin.save();
        console.log('-----------------------------------');
        console.log('Admin créé avec succès !');
        console.log('Identifiant : admin');
        console.log('Mot de passe : admin123');
        console.log('-----------------------------------');

        process.exit(0);
    } catch (error) {
        console.error('Erreur lors de la création de l\'admin:', error.message);
        process.exit(1);
    }
};

createAdmin();
