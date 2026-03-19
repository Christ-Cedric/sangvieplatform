const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Admin = require('./src/models/Admin');

dotenv.config();

const test = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        const admin = await Admin.findOne({ nomUtilisateur: 'admin' });
        if (admin) {
            console.log('Admin check:', admin.nomUtilisateur, 'Role:', admin.role);
            const isMatch = await admin.matchPassword('admin123');
            console.log('Password match:', isMatch);
        } else {
            console.log('Admin not found in DB');
        }
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
};
test();
