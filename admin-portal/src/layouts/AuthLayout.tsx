import React from 'react';
import { Outlet, Navigate } from 'react-router-dom';
import { useAuth } from '../features/auth/AuthContext';
import { Box, Paper, Grid, Typography, useTheme } from '@mui/material';

export const AuthLayout: React.FC = () => {
  const { isAuthenticated } = useAuth();
  const theme = useTheme();

  if (isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  return (
    <Grid container component="main" sx={{ minHeight: '100vh', overflow: 'hidden' }}>
      {/* Visual branding section - left side */}
      <Grid
        size={{ sm: 4, md: 7 }}
        sx={{
          display: { xs: 'none', sm: 'flex' },
          background: `linear-gradient(135deg, ${theme.palette.primary.dark} 0%, ${theme.palette.primary.main} 40%, ${theme.palette.secondary.main} 100%)`,
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          color: '#ffffff',
          p: 6,
          position: 'relative',
          overflow: 'hidden',
          '&::before': {
            content: '""',
            position: 'absolute',
            width: '150%',
            height: '150%',
            background: 'radial-gradient(circle, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0) 70%)',
            top: '-25%',
            left: '-25%',
            animation: 'pulse 15s infinite ease-in-out',
          },
          '@keyframes pulse': {
            '0%, 100%': { transform: 'scale(1)' },
            '50%': { transform: 'scale(1.1)' },
          },
        }}
      >
        <Box sx={{ position: 'relative', zIndex: 1, maxWidth: 520, textAlign: 'center' }}>
          <Typography
            variant="h2"
            component="h1"
            gutterBottom
            sx={{ fontWeight: 800, fontFamily: 'Outfit', letterSpacing: '-0.03em', lineHeight: 1.1 }}
          >
            RKCNL Survey Portal
          </Typography>
          <Typography variant="h6" sx={{ opacity: 0.9, fontWeight: 400, mb: 4, textTransform: 'uppercase', letterSpacing: '0.1em', fontSize: '0.9rem' }}>
            National Agricultural Resource Planning
          </Typography>
          <Typography variant="body1" sx={{ opacity: 0.8, fontSize: '1.1rem', lineHeight: 1.6 }}>
            Empowering field enumerators with robust, offline-first data collection and facilitating administration with live tracking, reporting, and secure RBAC survey controls.
          </Typography>
        </Box>
      </Grid>

      {/* Login Form area - right side */}
      <Grid
        size={{ xs: 12, sm: 8, md: 5 }}
        component={Paper}
        elevation={0}
        square
        sx={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          p: { xs: 4, md: 8 },
          bgcolor: 'background.default',
        }}
      >
        <Box sx={{ width: '100%', maxWidth: 400 }}>
          <Outlet />
        </Box>
      </Grid>
    </Grid>
  );
};
