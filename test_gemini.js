// Test with the correct model
const https = require('https');

const apiKey = 'AIzaSyDWw2Dy14i9vPiTt10RQjsWmgIMSfzTKeQ';
const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`;

const data = JSON.stringify({
    contents: [{
        parts: [{
            text: "What are the five pillars of Islam? Answer briefly."
        }]
    }]
});

const options = {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
    }
};

const req = https.request(url, options, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
        console.log('Status:', res.statusCode);
        try {
            const json = JSON.parse(body);
            if (json.candidates && json.candidates[0]) {
                console.log('AI Response:', json.candidates[0].content.parts[0].text);
            } else {
                console.log('Response:', JSON.stringify(json, null, 2));
            }
        } catch (e) {
            console.log('Raw:', body.substring(0, 500));
        }
    });
});

req.on('error', (e) => console.error('Error:', e.message));
req.write(data);
req.end();
