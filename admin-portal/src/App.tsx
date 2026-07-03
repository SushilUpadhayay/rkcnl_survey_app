import React, { useState, useMemo } from 'react';
import { RouterProvider } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider, CssBaseline } from '@mui/material';
import { AuthProvider } from './features/auth/AuthContext';
import { getTheme } from './theme/theme';
import { getRouter } from './routes';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

const App: React.FC = () => {
  // Read theme mode preference from localStorage, defaulting to 'light'
  const [mode, setMode] = useState<'light' | 'dark'>(() => {
    const saved = localStorage.getItem('themeMode');
    return (saved === 'dark' || saved === 'light') ? saved : 'light';
  });

  // Toggle theme mode and save to localStorage
  const handleSetMode = (newMode: 'light' | 'dark') => {
    setMode(newMode);
    localStorage.setItem('themeMode', newMode);
  };

  // Generate MUI theme dynamically on mode change
  const theme = useMemo(() => getTheme(mode), [mode]);

  // Generate routes config
  const router = useMemo(() => getRouter(mode, handleSetMode), [mode]);

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <AuthProvider>
          <RouterProvider router={router} />
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
};

export default App;
