import React from 'react';
import { createBrowserRouter } from 'react-router-dom';
import { AuthLayout } from '../layouts/AuthLayout';
import { DashboardLayout } from '../layouts/DashboardLayout';
import { ProtectedRoute } from '../features/auth/ProtectedRoute';
import { LoginPage } from '../features/auth/LoginPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { CategoryListPage } from '../features/categories/CategoryListPage';
import { SurveyListPage } from '../features/surveys/SurveyListPage';
import { SurveyDetailPage } from '../features/surveys/SurveyDetailPage';
import { QuestionBuilderPage } from '../features/surveys/QuestionBuilderPage';
import { UserListPage } from '../features/users/UserListPage';
import { AssignmentPage } from '../features/assignments/AssignmentPage';
import { ResponseListPage } from '../features/responses/ResponseListPage';
import { ReportsPage } from '../features/reports/ReportsPage';
import { ProfilePage } from '../features/users/ProfilePage';
import { Typography, Box, Button } from '@mui/material';

// Premium Page Not Found
const NotFound: React.FC = () => (
  <Box
    sx={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      height: '80vh',
      textAlign: 'center',
      p: 3,
    }}
  >
    <Typography variant="h1" color="primary" sx={{ fontSize: '6rem', fontWeight: 800, fontFamily: 'Outfit' }}>
      404
    </Typography>
    <Typography variant="h4" sx={{ fontWeight: 700, mb: 1.5, fontFamily: 'Outfit' }}>
      Page Not Found
    </Typography>
    <Typography variant="body1" color="text.secondary" sx={{ mb: 4, maxWidth: 460 }}>
      The administrative control page you are trying to access does not exist or has been moved.
    </Typography>
    <Button href="/" variant="contained" color="primary" sx={{ borderRadius: 2, px: 3, py: 1.2 }}>
      Return to Dashboard
    </Button>
  </Box>
);

export const getRouter = (
  mode: 'light' | 'dark',
  setMode: (mode: 'light' | 'dark') => void
) => {
  return createBrowserRouter([
    {
      element: <AuthLayout />,
      children: [
        {
          path: '/login',
          element: <LoginPage />,
        },
      ],
    },
    {
      element: (
        <ProtectedRoute>
          <DashboardLayout mode={mode} setMode={setMode} />
        </ProtectedRoute>
      ),
      children: [
        {
          path: '/',
          element: <DashboardPage />,
        },
        {
          path: '/categories',
          element: <CategoryListPage />,
        },
        {
          path: '/surveys',
          element: <SurveyListPage />,
        },
        {
          path: '/surveys/new',
          element: <QuestionBuilderPage />,
        },
        {
          path: '/surveys/:id',
          element: <SurveyDetailPage />,
        },
        {
          path: '/surveys/:id/edit',
          element: <QuestionBuilderPage />,
        },
        {
          path: '/users',
          element: <UserListPage />,
        },
        {
          path: '/assignments',
          element: <AssignmentPage />,
        },
        {
          path: '/responses',
          element: <ResponseListPage />,
        },
        {
          path: '/reports',
          element: <ReportsPage />,
        },
        {
          path: '/profile',
          element: <ProfilePage />,
        },
        {
          path: '*',
          element: <NotFound />,
        },
      ],
    },
  ]);
};
