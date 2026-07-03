import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor to attach JWT token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors (like 401)
let logoutCallback: (() => void) | null = null;

export const registerLogoutCallback = (cb: () => void) => {
  logoutCallback = cb;
};

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Clear storage
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      
      // Notify application if callback is registered
      if (logoutCallback) {
        logoutCallback();
      } else {
        // Fallback hard redirect to login if auth context is not yet loaded
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);
