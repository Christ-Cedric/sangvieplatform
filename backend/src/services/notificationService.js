const Notification = require('../models/Notification');

const createNotification = async (recipientId, recipientType, title, message, type = 'system') => {
    try {
        const notification = await Notification.create({
            to: recipientId,
            recipientType,
            title,
            message,
            type
        });
        return notification;
    } catch (error) {
        console.error('Error creating notification:', error.message);
    }
};

module.exports = { createNotification };
