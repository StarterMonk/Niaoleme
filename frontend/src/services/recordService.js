import api from './api';
import logger from '../utils/logger';

export const recordService = {
  async create(record) {
    try {
      const data = await api.post('/records', record);
      logger.info('Record created:', data.record?._id);
      return data;
    } catch (err) {
      logger.error('Create record failed:', err.message);
      throw err;
    }
  },

  async getAll(page = 1, limit = 20) {
    const data = await api.get('/records', { params: { page, limit } });
    return data;
  },

  async getStats() {
    const data = await api.get('/records/stats');
    return data;
  },

  async remove(id) {
    try {
      const data = await api.delete(`/records/${id}`);
      logger.info('Record removed:', id);
      return data;
    } catch (err) {
      logger.error('Remove record failed:', err.message);
      throw err;
    }
  },
};
