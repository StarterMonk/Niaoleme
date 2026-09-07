import api, { ApiError } from './api';
import AsyncStorage from '@react-native-async-storage/async-storage';
import logger from '../utils/logger';

const AUTH_KEYS = ['token', 'userId', 'username'];

export const authService = {
  async register(username, email, password) {
    try {
      const data = await api.post('/auth/register', { username, email, password });
      await AsyncStorage.multiSet([
        ['token', data.token],
        ['userId', data.user.id],
        ['username', data.user.username],
      ]);
      logger.info('User registered:', data.user.username);
      return data;
    } catch (err) {
      logger.error('Register failed:', err.message);
      throw err;
    }
  },

  async login(email, password) {
    try {
      const data = await api.post('/auth/login', { email, password });
      await AsyncStorage.multiSet([
        ['token', data.token],
        ['userId', data.user.id],
        ['username', data.user.username],
      ]);
      logger.info('User logged in:', data.user.username);
      return data;
    } catch (err) {
      logger.error('Login failed:', err.message);
      throw err;
    }
  },

  async logout() {
    await AsyncStorage.multiRemove(AUTH_KEYS);
    logger.info('User logged out');
  },

  async getProfile() {
    const data = await api.get('/auth/profile');
    return data.user;
  },

  async isLoggedIn() {
    const token = await AsyncStorage.getItem('token');
    return !!token;
  },

  async getUserId() {
    return AsyncStorage.getItem('userId');
  },
};
