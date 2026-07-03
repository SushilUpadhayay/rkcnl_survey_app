import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from './AuthContext';
import { CircularProgress, Box, Typography } from '@mui/material';

export const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated, user, isLoading } = useAuth();
  const location = useLocation();

  if (isLoading) {
    return (
      <Box
        sx={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          height: '100vh',
          backgroundColor: (theme) => theme.palette.background.default,
        }}
      >
        <CircularProgress size={50} thickness={4} />
        <Typography variant="body1" sx={{ mt: 2, color: 'text.secondary', fontWeight: 500 }}>
          Authenticating session...
        </Typography>
      </Box>
    );
  }

  if (!isAuthenticated || user?.role !== 'Admin') {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};
