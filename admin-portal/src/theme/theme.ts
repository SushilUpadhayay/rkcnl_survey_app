import { createTheme } from '@mui/material/styles';
import type { ThemeOptions } from '@mui/material/styles';

declare module '@mui/material/styles' {
  interface TypeBackground {
    default: string;
    paper: string;
    subtle?: string;
  }
}

export const getThemeOptions = (mode: 'light' | 'dark'): ThemeOptions => {
  const isDark = mode === 'dark';

  return {
    palette: {
      mode,
      primary: {
        main: '#008000', // AppColors.green
        light: '#C8E6C9', // AppColors.greenMid
        dark: '#006000', // AppColors.greenDark
        contrastText: '#ffffff',
      },
      secondary: {
        main: '#1565C0', // AppColors.blue
        light: '#E3F2FD', // AppColors.blueLight
        dark: '#0D47A1',
        contrastText: '#ffffff',
      },
      background: {
        default: isDark ? '#0F172A' : '#F5F8F5', // AppColors.darkBg vs AppColors.bg
        paper: isDark ? '#1E293B' : '#FFFFFF', // AppColors.darkSurface vs AppColors.surface
        subtle: isDark ? '#162032' : '#E8F5E9', // AppColors.darkSurfaceVariant vs AppColors.greenLight
      },
      text: {
        primary: isDark ? '#FFFFFF' : '#1A2E1A', // AppColors.darkTextPrimary vs AppColors.textPrimary
        secondary: isDark ? '#94A3B8' : '#546E54', // AppColors.darkTextSub vs AppColors.textSub
        disabled: isDark ? '#64748B' : '#90A890', // AppColors.darkTextMuted vs AppColors.textMuted
      },
      divider: isDark ? '#334155' : '#E0EDE0', // AppColors.darkBorder vs AppColors.border
    },
    typography: {
      fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
      h1: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 700,
        fontSize: '2.5rem',
      },
      h2: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 700,
        fontSize: '2rem',
      },
      h3: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 600,
        fontSize: '1.75rem',
      },
      h4: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 600,
        fontSize: '1.5rem',
      },
      h5: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 600,
        fontSize: '1.25rem',
      },
      h6: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 600,
        fontSize: '1rem',
      },
      subtitle1: {
        fontFamily: '"Inter", sans-serif',
        fontWeight: 500,
      },
      subtitle2: {
        fontFamily: '"Inter", sans-serif',
        fontWeight: 500,
      },
      body1: {
        fontFamily: '"Inter", sans-serif',
        fontSize: '0.975rem',
        lineHeight: 1.6,
      },
      body2: {
        fontFamily: '"Inter", sans-serif',
        fontSize: '0.875rem',
        lineHeight: 1.5,
      },
      button: {
        fontFamily: '"Outfit", sans-serif',
        fontWeight: 600,
        textTransform: 'none',
      },
    },
    shape: {
      borderRadius: 12,
    },
    components: {
      MuiButton: {
        styleOverrides: {
          root: {
            borderRadius: 12, // App border radius
            padding: '8px 16px',
            transition: 'all 0.2s ease-in-out',
            boxShadow: 'none',
            '&:hover': {
              boxShadow: 'none',
              transform: 'translateY(-1px)',
            },
            '&:active': {
              transform: 'translateY(0)',
            },
            '&.MuiButton-containedPrimary:hover': {
              backgroundColor: '#006000', // AppColors.greenDark
            },
          },
        },
      },
      MuiCard: {
        styleOverrides: {
          root: {
            backgroundImage: 'none',
            borderRadius: 12, // App card border radius
            boxShadow: isDark
              ? '0 4px 6px -1px rgba(0, 0, 0, 0.3), 0 2px 4px -1px rgba(0, 0, 0, 0.2)'
              : '0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.02)',
            border: `1px solid ${isDark ? '#334155' : '#E0EDE0'}`,
          },
        },
      },
      MuiPaper: {
        styleOverrides: {
          root: {
            backgroundImage: 'none',
          },
        },
      },
      MuiTableCell: {
        styleOverrides: {
          root: {
            borderBottom: `1px solid ${isDark ? '#334155' : '#E0EDE0'}`,
            padding: '16px',
          },
          head: {
            fontWeight: 600,
            backgroundColor: isDark ? '#162032' : '#E8F5E9',
            color: isDark ? '#FFFFFF' : '#1A2E1A',
          },
        },
      },
    },
  };
};

export const getTheme = (mode: 'light' | 'dark') => {
  return createTheme(getThemeOptions(mode));
};
