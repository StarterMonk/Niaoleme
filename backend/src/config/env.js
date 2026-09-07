const NODE_ENV = process.env.NODE_ENV || 'development';

const required = (name, fallback) => {
  const v = process.env[name];
  if (!v || v.trim() === '' || v.startsWith('CHANGE_ME')) {
    if (NODE_ENV === 'production') {
      throw new Error(`[config] Required env var ${name} is missing or placeholder in production`);
    }
    return fallback || v;
  }
  return v;
};

module.exports = {
  NODE_ENV,
  PORT: parseInt(process.env.PORT || '8080', 10),
  MONGODB_URI: required('MONGODB_URI', 'mongodb://localhost:27017/urine-health'),
  JWT_SECRET: required('JWT_SECRET', 'dev-only-insecure-secret-do-not-use-in-prod'),
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  CORS_ORIGINS: (process.env.CORS_ORIGINS || '').split(',').map(s => s.trim()).filter(Boolean),
};
