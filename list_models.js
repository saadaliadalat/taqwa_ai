// List available Gemini models
const https = require('https');

const apiKey = 'AIzaSyDWw2Dy14i9vPiTt10RQjsWmgIMSfzTKeQ';
const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`;

https.get(url, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
        console.log('Status:', res.statusCode);
        const data = JSON.parse(body);
        if (data.models) {
            data.models.forEach(m => {
                console.log('Model:', m.name, '- Methods:', m.supportedGenerationMethods?.join(', '));
            });
        } else {
            console.log(body);
        }
    });
});
