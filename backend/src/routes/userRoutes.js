
/**
 * @swagger
 * tags:
 *   name: User
 *   description: Routes utilisateur
 */
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { updateDonorStatus, getMyDonations, respondToRequest, updateProfile } = require('../controllers/userController');

/**
 * @swagger
 * /api/users/profile:
 *   put:
 *     summary: Mettre à jour le profil
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profil mis à jour
 */
router.put('/profile', protect, updateProfile);

/**
 * @swagger
 * /api/users/respond/{requestId}:
 *   post:
 *     summary: Répondre à une demande de sang
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: requestId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       201:
 *         description: Réponse enregistrée
 */
router.post('/respond/:requestId', protect, respondToRequest);

/**
 * @swagger
 * /api/users/status:
 *   put:
 *     summary: Changer le statut du donneur (Actif/Inactif)
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               statutDonneur: { type: string, enum: ['actif', 'inactif'] }
 *     responses:
 *       200:
 *         description: Statut mis à jour
 */
router.put('/status', protect, updateDonorStatus);

/**
 * @swagger
 * /api/users/my-donations:
 *   get:
 *     summary: Consulter l'historique de ses propres dons
 *     tags: [User]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des dons retournée
 */
router.get('/my-donations', protect, getMyDonations);

module.exports = router;
