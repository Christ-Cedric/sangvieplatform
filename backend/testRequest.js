const axios = require('axios');

async function test() {
    try {
        // 1. Login as hospital
        const loginRes = await axios.post('http://localhost:5000/api/auth/login', {
            identifier: 'contact@chu-yo.bf', // Assuming this exists from mock or prior knowledge
            motDePasse: 'hospital123'
        });
        const token = loginRes.data.token;
        console.log('Logged in, token received');

        // 2. Create request
        const res = await axios.post('http://localhost:5000/api/hospitals/request', {
            groupeSanguin: 'O+',
            quantitePoches: 5,
            niveauUrgence: 'critique',
            description: 'Test emergency'
        }, {
            headers: { Authorization: `Bearer ${token}` }
        });
        console.log('Request created successfully:', res.data);
    } catch (error) {
        console.error('Error:', error.response ? error.response.data : error.message);
    }
}

test();
