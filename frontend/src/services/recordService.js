import api from './api';

export const recordService = {
  async create(record) {
    const { data } = await api.post('/records', record);
    return data;
  },

  async getAll(page = 1, limit = 20) {
    const { data } = await api.get('/records', { params: { page, limit } });
    return data;
  },

  async getStats() {
    const { data } = await api.get('/records/stats');
    return data;
  },

  async remove(id) {
    const { data } = await api.delete(`/records/${id}`);
    return data;
  },
};
