const mongoose = require('mongoose');
const Admin = require('./src/models/Admin');
require('dotenv').config();

const reset = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('Connecté à MongoDB');

        // Supprimer tous les admins existants pour repartir de zéro
        await Admin.deleteMany({});
        console.log('Anciens comptes admin supprimés');

        // Créer le nouveau compte
        const newAdmin = await Admin.create({
            nomUtilisateur: 'admin_sangvie',
            email: 'admin@sangvie.com',
            motDePasse: 'AdminSangVie123!'
        });

        console.log('Nouveau compte admin créé avec succès :');
        console.log('Identifiant/Email : admin@sangvie.com');
        console.log('Username : admin_sangvie');
        console.log('Mot de passe : AdminSangVie123!');

    } catch (error) {
        console.error('Erreur :', error);
    } finally {
        await mongoose.connection.close();
        process.exit();
    }
};

reset();
