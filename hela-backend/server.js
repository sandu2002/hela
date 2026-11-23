require('dotenv').config();
const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const tourRoutes = require('./routes/tourRoutes');
const destinationRoutes = require('./routes/destinationRoutes');
const rideRoutes = require('./routes/rideRoutes');
const stayRoutes = require('./routes/stayRoutes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json());

// API Health Check & Welcome
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    service: 'HELA Mobile & Web Backend API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      tours: '/api/tours',
      destinations: '/api/destinations',
      rides: '/api/rides',
      stays: '/api/stays',
    },
    insforgeConnected: true,
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/tours', tourRoutes);
app.use('/api/destinations', destinationRoutes);
app.use('/api/rides', rideRoutes);
app.use('/api/stays', stayRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(500).json({ error: 'Internal Server Error', message: err.message });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 HELA Backend server running on http://localhost:${PORT}`);
  console.log(`📡 Connected to InsForge BaaS at ${process.env.INSFORGE_BASE_URL || 'https://tvf24g8r.us-east.insforge.app'}`);
});

module.exports = app;
