import React, { createContext, useContext, useState, useEffect } from 'react';
import type { User } from '../../types';
import { apiClient, registerLogoutCallback } from '../../api/client';

interface AuthContextType {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<User>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [isLoading, setIsLoading] = useState(true);

  // Define logout function
  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setToken(null);
    setUser(null);
  };

  // Register logout callback for Axios interceptor 401s
  useEffect(() => {
    registerLogoutCallback(logout);
  }, []);

  // Check token validity & fetch profile on load
  useEffect(() => {
    const initAuth = async () => {
      const storedToken = localStorage.getItem('token');

      if (storedToken) {
        try {
          // Verify with server profile call
          const response = await apiClient.get('/auth/profile');
          const profileData = response.data.data;
          
          // Double check role
          if (profileData.role !== 'Admin') {
            throw new Error('Access denied. Admin role required.');
          }

          setUser(profileData);
          localStorage.setItem('user', JSON.stringify(profileData));
        } catch (error) {
          console.error('Session restore failed:', error);
          logout();
        }
      } else {
        logout();
      }
      setIsLoading(false);
    };

    initAuth();
  }, [token]);

  const login = async (email: string, password: string): Promise<User> => {
    try {
      const response = await apiClient.post('/auth/login', { email, password });
      
      const { token: receivedToken, data: userData } = response.data;

      // Validate role - Admin web portal is Admin-only
      if (userData.role !== 'Admin') {
        throw new Error('Access denied. Only Admins can log in to the portal.');
      }

      // Check active state
      if (!userData.isActive) {
        throw new Error('This account has been deactivated. Please contact support.');
      }

      localStorage.setItem('token', receivedToken);
      localStorage.setItem('user', JSON.stringify(userData));
      
      setToken(receivedToken);
      setUser(userData);
      
      return userData;
    } catch (error: any) {
      const msg = error.response?.data?.message || error.message || 'Login failed';
      throw new Error(msg);
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: !!user,
        isLoading,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
