const swaggerJsdoc = require('swagger-jsdoc');

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Blood Donation Platform API',
            version: '1.0.0',
            description: 'Documentation de l\'API pour la plateforme de don de sang (UML Aligned)',
        },
        servers: [
            {
                url: 'http://localhost:5000',
                description: 'Serveur de développement',
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        },
    },
    apis: ['./src/routes/*.js', './src/models/*.js'], // Chemins vers les fichiers contenant des annotations
};

const specs = swaggerJsdoc(options);
module.exports = specs;
