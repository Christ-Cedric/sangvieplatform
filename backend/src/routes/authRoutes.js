const express = require('express');
const router = express.Router();
const { registerUser, registerHospital, login } = require('../controllers/authController');

/**
 * @swagger
 * /api/auth/register-user:
 *   post:
 *     summary: Inscrire un nouvel utilisateur (donneur)
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nom: { type: string }
 *               prenom: { type: string }
 *               email: { type: string }
 *               motDePasse: { type: string }
 *               telephone: { type: string }
 *               lieuResidence: { type: string }
 *               groupeSanguin: { type: string }
 *     responses:
 *       201:
 *         description: Utilisateur créé avec succès
 */
router.post('/register-user', registerUser);

/**
 * @swagger
 * /api/auth/register-hospital:
 *   post:
 *     summary: Inscrire un nouvel hôpital
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nom: { type: string }
 *               email: { type: string }
 *               motDePasse: { type: string }
 *               numeroAgrement: { type: string }
 *               contact: { type: string }
 *               region: { type: string }
 *               localisation: { type: string }
 *     responses:
 *       201:
 *         description: Hôpital créé avec succès
 */
router.post('/register-hospital', registerHospital);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Connexion universelle (Utilisateur, Hôpital, Admin)
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               telephone: { type: string, description: "Requis pour User (ex: 01020304)" }
 *               contact: { type: string, description: "Requis pour Hospital (ex: 70809000)" }
 *               nomUtilisateur: { type: string, description: "Requis pour Admin" }
 *               motDePasse: { type: string }
 *     responses:
 *       200:
 *         description: Connexion réussie, retourne un token JWT
 */
router.post('/login', login);

module.exports = router;
