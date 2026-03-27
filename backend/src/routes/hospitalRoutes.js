
/**
 * @swagger
 * tags:
 *   name: Hospital
 *   description: Routes hôpital
 */
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

const { 
    createRequest, 
    getMyRequests, 
    updateProfile, 
    confirmDonation, 
    getStats,
    getRequestResponses,
    getNotifications,
    markNotificationsAsRead,
    updateRequestStatus,
    getAllHospitalsPublic
} = require('../controllers/hospitalController');

/**
 * @swagger
 * /api/hospitals:
 *   get:
 *     summary: Récupérer la liste des hôpitaux publics
 *     tags: [Hospital]
 *     responses:
 *       200:
 *         description: Liste des hôpitaux
 */
router.get('/', getAllHospitalsPublic);

/**
 * @swagger
 * /api/hospitals/request/{requestId}:
 *   put:
 *     summary: Mettre à jour le statut d'une demande
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: requestId
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               statut: { type: string, enum: ['en_attente', 'satisfait', 'annule'] }
 *     responses:
 *       200:
 *         description: Demande mise à jour
 */
router.put('/request/:requestId', protect, authorize('hospital'), updateRequestStatus);

/**
 * @swagger
 * /api/hospitals/stats:
 *   get:
 *     summary: Consulter les statistiques de l'hôpital
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Statistiques de l'hôpital
 */
router.get('/stats', protect, authorize('hospital'), getStats);

/**
 * @swagger
 * /api/hospitals/confirm-donation/:donationId:
 *   put:
 *     summary: Confirmer un don effectué
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Don confirmé
 */
router.put('/confirm-donation/:donationId', protect, authorize('hospital'), confirmDonation);

/**
 * @swagger
 * /api/hospitals/profile:
 *   put:
 *     summary: Mettre à jour le profil de l'hôpital
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profil mis à jour
 */
router.put('/profile', protect, authorize('hospital'), updateProfile);

/**
 * @swagger
 * /api/hospitals/request:
 *   post:
 *     summary: Créer une demande de sang urgente
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               groupeSanguin: { type: string, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] }
 *               quantitePoches: { type: number }
 *               niveauUrgence: { type: string, enum: ['normal', 'urgent', 'critique'] }
 *               description: { type: string }
 *     responses:
 *       201:
 *         description: Demande créée et notifications envoyées
 */
router.post('/request', protect, authorize('hospital'), createRequest);

/**
 * @swagger
 * /api/hospitals/my-requests:
 *   get:
 *     summary: Consulter l'historique des demandes de l'hôpital
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des demandes
 */
router.get('/my-requests', protect, authorize('hospital'), getMyRequests);

/**
 * @swagger
 * /api/hospitals/request-responses/{requestId}:
 *   get:
 *     summary: Voir les donneurs ayant répondu à une demande
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: requestId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Liste des donneurs
 */
router.get('/request-responses/:requestId', protect, authorize('hospital'), getRequestResponses);

/**
 * @swagger
 * /api/hospitals/notifications:
 *   get:
 *     summary: Voir les notifications de l'hôpital
 *     tags: [Hospital]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste des notifications
 */
router.get('/notifications', protect, authorize('hospital'), getNotifications);
router.put('/notifications/read', protect, authorize('hospital'), markNotificationsAsRead);

module.exports = router;
