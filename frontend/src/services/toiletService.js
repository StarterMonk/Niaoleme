import api from './api';
import logger from '../utils/logger';

export const toiletService = {
  async getNearby(latitude, longitude, maxDistance = 5000) {
    const data = await api.get('/toilets', {
      params: { latitude, longitude, maxDistance },
    });
    return data;
  },

  async getDetail(id) {
    const data = await api.get(`/toilets/${id}`);
    return data;
  },

  async create(toilet) {
    try {
      const data = await api.post('/toilets', toilet);
      logger.info('Toilet created:', data.toilet?.name);
      return data;
    } catch (err) {
      logger.error('Create toilet failed:', err.message);
      throw err;
    }
  },

  async rate(id, rating) {
    try {
      const data = await api.post(`/toilets/${id}/rate`, rating);
      logger.info('Toilet rated:', id);
      return data;
    } catch (err) {
      logger.error('Rate toilet failed:', err.message);
      throw err;
    }
  },
};
