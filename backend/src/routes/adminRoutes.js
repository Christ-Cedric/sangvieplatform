
/**
 * @swagger
 * tags:
 *   name: Admin
 *   description: Routes administrateur
 */
const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');
const { verifyHospital, deleteAccount, getStats, getPendingHospitals, getAllHospitals, getAllUsers, getReports } = require('../controllers/adminController');

/**
 * @swagger
 * /api/admin/pending-hospitals:
 *   get:
 *     summary: Liste des hôpitaux en attente de validation
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Liste retournée
 */
router.get('/pending-hospitals', protect, authorize('admin'), getPendingHospitals);
router.get('/hospitals', protect, authorize('admin'), getAllHospitals);
router.get('/users', protect, authorize('admin'), getAllUsers);
router.get('/reports', protect, authorize('admin'), getReports);

/**
 * @swagger
 * /api/admin/verify-hospital/{id}:
 *   put:
 *     summary: Valider un compte d'hôpital
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Hôpital validé
 *       404:
 *         description: Hôpital non trouvé
 */
router.put('/verify-hospital/:id', protect, authorize('admin'), verifyHospital);

/**
 * @swagger
 * /api/admin/account/{id}:
 *   delete:
 *     summary: Supprimer un compte (Utilisateur ou Hôpital)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *       - in: query
 *         name: type
 *         required: true
 *         schema:
 *           type: string
 *           enum: [User, Hospital]
 *     responses:
 *       200:
 *         description: Compte supprimé
 */
router.delete('/account/:id', protect, authorize('admin'), deleteAccount);

/**
 * @swagger
 * /api/admin/stats:
 *   get:
 *     summary: Obtenir les statistiques globales
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Statistiques retournées
 */
router.get('/stats', protect, authorize('admin'), getStats);

module.exports = router;
