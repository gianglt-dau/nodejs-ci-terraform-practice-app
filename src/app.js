const express = require('express');

const app = express();

app.get('/', (req, res) => {
  res.send('Hello from Node.js practice app!');
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

module.exports = app;
