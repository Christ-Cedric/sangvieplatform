const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const hospitalSchema = new mongoose.Schema({
    nom: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    numeroAgrement: { type: String, required: true },
    contact: { type: String, required: true },
    region: { type: String, required: true },
    localisation: { type: String, required: true },
    motDePasse: { type: String, required: true },
    verified: { type: Boolean, default: false },
    role: { type: String, default: 'hospital' }
}, { timestamps: true });

hospitalSchema.pre('save', async function () {
    if (!this.isModified('motDePasse')) return;
    const salt = await bcrypt.genSalt(10);
    this.motDePasse = await bcrypt.hash(this.motDePasse, salt);
});

hospitalSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.motDePasse);
};

module.exports = mongoose.model('Hospital', hospitalSchema);
