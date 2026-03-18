const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { sendMessage, getConversationMessages, getConversations } = require('../controllers/messageController');

router.post('/', protect, sendMessage);
router.get('/conversations', protect, getConversations);
router.get('/:otherId', protect, getConversationMessages);

module.exports = router;
