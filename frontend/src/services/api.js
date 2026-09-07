import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE = process.env.EXPO_PUBLIC_API_BASE_URL || 'http://localhost:8080/api/v1';

export class ApiError extends Error {
  constructor(message, status, code) {
    super(message);
    this.status = status;
    this.code = code;
    this.name = 'ApiError';
  }
}

const api = axios.create({
  baseURL: API_BASE,
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' },
});

api.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => {
    const body = response.data;
    if (body && body.error) {
      const err = body.error;
      throw new ApiError(err.message || 'Request failed', response.status, err.code);
    }
    return body !== undefined ? body : response;
  },
  (error) => {
    if (error.response?.status === 401) {
      AsyncStorage.multiRemove(['token', 'userId', 'username']);
    }
    if (error.response?.data?.error) {
      const { message, code } = error.response.data.error;
      throw new ApiError(message || error.message, error.response.status, code);
    }
    throw new ApiError(error.message, error.response?.status || 0, 'NETWORK_ERROR');
  }
);

export default api;
