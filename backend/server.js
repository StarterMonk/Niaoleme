require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const mongoSanitize = require('express-mongo-sanitize');

const connectDB = require('./src/config/db');
const env = require('./src/config/env');
const { errorHandler } = require('./src/middleware/errorHandler');
const { apiLimiter } = require('./src/middleware/rateLimit');

const app = express();

connectDB();

app.set('trust proxy', 1);

app.use(helmet());
app.use(cors({
  origin: env.CORS_ORIGINS.length > 0 ? env.CORS_ORIGINS : false,
  credentials: true,
}));
app.use(express.json({ limit: '10kb' }));
app.use(compression());
app.use(mongoSanitize());
app.use(morgan(env.NODE_ENV === 'production' ? 'combined' : 'dev'));

app.get('/api/v1/health', async (req, res) => {
  const dbState = require('mongoose').connection.readyState;
  const healthy = dbState === 1;
  res.status(healthy ? 200 : 503).json({
    status: healthy ? 'ok' : 'degraded',
    db: dbState,
    timestamp: new Date().toISOString(),
    env: env.NODE_ENV,
  });
});

app.use('/api/v1', apiLimiter);
app.use('/api/v1/auth', require('./src/routes/auth'));
app.use('/api/v1/records', require('./src/routes/records'));
app.use('/api/v1/toilets', require('./src/routes/toilets'));

app.use((req, res) => {
  res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Route not found' } });
});

app.use(errorHandler);

const server = app.listen(env.PORT, () => {
  console.log(`[server] running on port ${env.PORT} (${env.NODE_ENV})`);
});

const shutdown = (signal) => {
  console.log(`[server] received ${signal}, shutting down`);
  server.close(() => {
    require('mongoose').connection.close(false, () => process.exit(0));
  });
  setTimeout(() => process.exit(1), 10000).unref();
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('unhandledRejection', (err) => {
  console.error('[unhandledRejection]', err);
});

module.exports = app;
