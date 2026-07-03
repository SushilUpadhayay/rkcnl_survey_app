import React from 'react';
import { Card, CardContent, Typography, Box, Avatar, useTheme, alpha } from '@mui/material';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  color?: 'primary' | 'secondary' | 'success' | 'warning' | 'error' | 'info';
  description?: string;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  icon,
  color = 'primary',
  description,
}) => {
  const theme = useTheme();

  // Pick color shades based on theme options dynamically
  const getColorShades = () => {
    switch (color) {
      case 'primary':
        return {
          bg: alpha(theme.palette.primary.main, theme.palette.mode === 'dark' ? 0.15 : 0.08),
          text: theme.palette.primary.main,
        };
      case 'secondary':
        return {
          bg: alpha(theme.palette.secondary.main, theme.palette.mode === 'dark' ? 0.15 : 0.08),
          text: theme.palette.secondary.main,
        };
      case 'success':
        return {
          bg: alpha(theme.palette.success.main, theme.palette.mode === 'dark' ? 0.15 : 0.08),
          text: theme.palette.success.main,
        };
      case 'warning':
        return {
          bg: alpha(theme.palette.warning.main, theme.palette.mode === 'dark' ? 0.15 : 0.08),
          text: theme.palette.warning.main,
        };
      case 'error':
        return {
          bg: alpha(theme.palette.error.main, theme.palette.mode === 'dark' ? 0.15 : 0.08),
          text: theme.palette.error.main,
        };
      default:
        return {
          bg: alpha(theme.palette.info.main, theme.palette.mode === 'dark' ? 0.15 : 0.08),
          text: theme.palette.info.main,
        };
    }
  };

  const shades = getColorShades();

  return (
    <Card
      sx={{
        overflow: 'hidden',
        position: 'relative',
        transition: 'transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: theme.palette.mode === 'dark' 
            ? '0 12px 20px -10px rgba(0, 0, 0, 0.5)' 
            : `0 12px 20px -10px ${alpha(theme.palette.primary.main, 0.12)}`,
        },
      }}
    >
      <CardContent sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
          <Typography variant="body2" sx={{ fontWeight: 600, color: 'text.secondary', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
            {title}
          </Typography>
          <Avatar
            sx={{
              bgcolor: shades.bg,
              color: shades.text,
              width: 48,
              height: 48,
              borderRadius: 2.5,
            }}
          >
            {icon}
          </Avatar>
        </Box>
        <Typography
          variant="h3"
          component="div"
          sx={{
            fontWeight: 800,
            fontFamily: 'Outfit',
            color: 'text.primary',
            mb: description ? 1 : 0,
            letterSpacing: '-0.02em',
          }}
        >
          {value}
        </Typography>
        {description && (
          <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>
            {description}
          </Typography>
        )}
      </CardContent>
    </Card>
  );
};
