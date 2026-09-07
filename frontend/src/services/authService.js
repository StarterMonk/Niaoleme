import api from './api';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const authService = {
  async register(username, email, password) {
    const { data } = await api.post('/auth/register', { username, email, password });
    if (data.success) {
      await AsyncStorage.multiSet([
        ['token', data.token],
        ['userId', data.user.id],
        ['username', data.user.username],
      ]);
    }
    return data;
  },

  async login(email, password) {
    const { data } = await api.post('/auth/login', { email, password });
    if (data.success) {
      await AsyncStorage.multiSet([
        ['token', data.token],
        ['userId', data.user.id],
        ['username', data.user.username],
      ]);
    }
    return data;
  },

  async logout() {
    await AsyncStorage.multiRemove(['token', 'userId', 'username']);
  },

  async getProfile() {
    const { data } = await api.get('/auth/profile');
    return data.user;
  },

  async isLoggedIn() {
    const token = await AsyncStorage.getItem('token');
    return !!token;
  },
};
