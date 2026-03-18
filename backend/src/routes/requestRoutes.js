
/**
 * @swagger
 * tags:
 *   name: Request
 *   description: Routes de demande de sang
 */
const express = require('express');
const router = express.Router();
const { getAllRequests } = require('../controllers/requestController');

/**
 * @swagger
 * /api/requests:
 *   get:
 *     summary: Obtenir tous les besoins en sang (Fil d'actualité public)
 *     tags: [Request]
 *     responses:
 *       200:
 *         description: Liste des demandes de sang en cours
 */
router.get('/', getAllRequests);

module.exports = router;
