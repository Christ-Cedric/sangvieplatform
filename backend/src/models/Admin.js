const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const adminSchema = new mongoose.Schema({
    nomUtilisateur: { type: String, required: true, unique: true },
    email: { type: String, unique: true, sparse: true },
    motDePasse: { type: String, required: true },
    role: { type: String, default: 'admin' }
}, { timestamps: true });

adminSchema.pre('save', async function () {
    if (!this.isModified('motDePasse')) return;
    const salt = await bcrypt.genSalt(10);
    this.motDePasse = await bcrypt.hash(this.motDePasse, salt);

});

adminSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.motDePasse);
};

module.exports = mongoose.model('Admin', adminSchema);
