const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 10000;

// Database connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// Initialize database schema
async function initializeDatabase() {
  try {
    console.log('Initializing database schema...');
    
    // Read schema file
    const schemaPath = path.join(__dirname, 'database', 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    // Execute schema
    await pool.query(schema);
    
    console.log('✅ Database schema initialized successfully');
  } catch (error) {
    console.error('⚠️ Database initialization warning:', error.message);
    // Don't exit on error - schema might already exist
  }
}

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW()');
    res.json({
      success: true,
      database: 'connected',
      timestamp: result.rows[0].now
    });
  } catch (error) {
    res.status(503).json({
      success: false,
      database: 'disconnected',
      error: error.message
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'ShaadiCapture Pro API v2.0',
    status: 'running',
    version: '2.0.0',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      leads: '/api/leads',
      photographers: '/api/photographers',
      bookings: '/api/bookings',
      locations: '/api/locations',
      keywords: '/api/keywords',
      admin: '/api/admin'
    }
  });
});

// Import routes
const authRoutes = require('./routes/auth');
const leadsRoutes = require('./routes/leads');
const photographersRoutes = require('./routes/photographers');
const bookingsRoutes = require('./routes/bookings');
const locationsRoutes = require('./routes/locations');
const keywordsRoutes = require('./routes/keywords');
const adminRoutes = require('./routes/admin');

// Register routes
app.use('/api/auth', authRoutes(pool));
app.use('/api/leads', leadsRoutes(pool));
app.use('/api/photographers', photographersRoutes(pool));
app.use('/api/bookings', bookingsRoutes(pool));
app.use('/api/locations', locationsRoutes(pool));
app.use('/api/keywords', keywordsRoutes(pool));
app.use('/api/admin', adminRoutes(pool));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    error: err.message || 'Internal Server Error'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path
  });
});

// Start server
async function startServer() {
  try {
    // Initialize database
    await initializeDatabase();
    
    // Start listening
    app.listen(PORT, () => {
      console.log(`
╔════════════════════════════════════════════╗
║   ShaadiCapture Pro v2.0 - API Server      ║
╚════════════════════════════════════════════╝
✅ Server running on PORT: ${PORT}
✅ Environment: ${process.env.NODE_ENV || 'development'}
✅ Database: Connected
✅ Ready to accept requests
📍 URL: http://localhost:${PORT}
      `);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Export pool for use in routes
app.locals.pool = pool;

// Start the server
startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  await pool.end();
  process.exit(0);
});

module.exports = app;
