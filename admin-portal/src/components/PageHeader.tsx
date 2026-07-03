import React from 'react';
import { Box, Typography, Divider } from '@mui/material';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  action?: React.ReactNode;
}

export const PageHeader: React.FC<PageHeaderProps> = ({ title, subtitle, action }) => {
  return (
    <Box sx={{ mb: 4 }}>
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: { xs: 'flex-start', sm: 'center' },
          flexDirection: { xs: 'column', sm: 'row' },
          gap: 2,
          mb: 1.5,
        }}
      >
        <Box>
          <Typography
            variant="h3"
            component="h1"
            sx={{
              fontWeight: 700,
              fontFamily: 'Outfit',
              color: 'text.primary',
              letterSpacing: '-0.02em',
            }}
          >
            {title}
          </Typography>
          {subtitle && (
            <Typography variant="body1" color="text.secondary" sx={{ mt: 0.5 }}>
              {subtitle}
            </Typography>
          )}
        </Box>
        {action && <Box sx={{ alignSelf: { xs: 'flex-end', sm: 'center' } }}>{action}</Box>}
      </Box>
      <Divider sx={{ borderStyle: 'dashed' }} />
    </Box>
  );
};
