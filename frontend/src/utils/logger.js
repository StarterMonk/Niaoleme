const isDev = __DEV__;

const logger = {
  info: (...args) => {
    if (isDev) console.log('[INFO]', ...args);
  },
  warn: (...args) => {
    if (isDev) console.warn('[WARN]', ...args);
  },
  error: (...args) => {
    if (isDev) console.error('[ERROR]', ...args);
  },
  debug: (...args) => {
    if (isDev) console.log('[DEBUG]', ...args);
  },
};

export default logger;
