const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./src/models/User');
require('dotenv').config();

const createAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB connectée');

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash('admin123', salt);

        const admin = await User.findOneAndUpdate(
            { email: 'admin@sangvie.com' },
            {
                nom: 'Admin',
                prenom: 'System',
                email: 'admin@sangvie.com',
                password: hashedPassword,
                role: 'admin',
                telephone: '00000000',
                lieuResidence: 'National',
                groupeSanguin: 'O+'
            },
            { upsert: true, new: true }
        );

        console.log('Admin créé/mis à jour avec succès :');
        console.log('Email: admin@sangvie.com');
        console.log('Password: admin123');
        
        process.exit();
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
};

createAdmin();
