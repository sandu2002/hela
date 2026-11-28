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
const isProduction = process.env.NODE_ENV === 'production';

// Security headers & payload limits
app.disable('x-powered-by');
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  next();
});

const allowedOrigins = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

app.use(
  cors(
    allowedOrigins.length > 0
      ? {
          origin(origin, callback) {
            if (!origin || allowedOrigins.includes(origin)) {
              return callback(null, true);
            }
            return callback(new Error('Origin not allowed by CORS'));
          },
        }
      : undefined,
  ),
);
app.use(express.json({ limit: '256kb' }));

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

// Error handling middleware (avoid leaking stack/internal errors in production)
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err?.message || err);
  const status = err?.statusCode && err.statusCode >= 400 && err.statusCode < 600 ? err.statusCode : 500;
  res.status(status).json({
    error: status === 500 ? 'Internal Server Error' : err.message,
    ...(isProduction ? {} : { message: err.message }),
  });
});

// Start server only when executed directly (keeps module cleanly testable)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`🚀 HELA Backend server running on http://localhost:${PORT}`);
  });
}

module.exports = app;
