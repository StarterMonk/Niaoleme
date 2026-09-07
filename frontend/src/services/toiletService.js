import api from './api';

export const toiletService = {
  async getNearby(latitude, longitude) {
    const { data } = await api.get('/toilets', { params: { latitude, longitude } });
    return data;
  },

  async getDetail(id) {
    const { data } = await api.get(`/toilets/${id}`);
    return data;
  },

  async create(toilet) {
    const { data } = await api.post('/toilets', toilet);
    return data;
  },

  async rate(id, rating) {
    const { data } = await api.post(`/toilets/${id}/rate`, rating);
    return data;
  },
};
