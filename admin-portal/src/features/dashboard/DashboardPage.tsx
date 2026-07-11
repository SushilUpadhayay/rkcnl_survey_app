import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../../api/client';
import type { DashboardStats } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import { StatCard } from '../../components/StatCard';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  CircularProgress,
  Alert,
  List,
  ListItem,
  ListItemText,
  ListItemAvatar,
  Avatar,
  Divider,
} from '@mui/material';
import {
  People as PeopleIcon,
  Checklist as ChecklistIcon,
  Poll as PollIcon,
} from '@mui/icons-material';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip as ChartTooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';

export const DashboardPage: React.FC = () => {
  // Fetch stats using TanStack Query
  const { data, isLoading, error } = useQuery<DashboardStats>({
    queryKey: ['dashboard-stats'],
    queryFn: async () => {
      const response = await apiClient.get('/dashboard/stats');
      return response.data.data;
    },
  });

  // Fetch recent responses to show in recent activity section
  const { data: responsesData, isLoading: loadingResponses } = useQuery({
    queryKey: ['recent-responses'],
    queryFn: async () => {
      const response = await apiClient.get('/responses?limit=5');
      return response.data.data || [];
    },
  });

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
        <CircularProgress size={50} />
      </Box>
    );
  }

  if (error) {
    return (
      <Box sx={{ p: 2 }}>
        <Alert severity="error">Failed to load dashboard statistics. Please try again later.</Alert>
      </Box>
    );
  }

  // Fallback values if data is undefined
  const stats = data || {
    totalUsers: 0,
    activeUsers: 0,
    totalSurveys: 0,
    activeSurveys: 0,
    totalResponses: 0,
  };

  // Mock chart data based on stats
  const barChartData = [
    { name: 'Users', total: stats.totalUsers, active: stats.activeUsers },
    { name: 'Surveys', total: stats.totalSurveys, active: stats.activeSurveys },
  ];

  const pieChartData = [
    { name: 'Active Surveys', value: stats.activeSurveys },
    { name: 'Draft/Closed Surveys', value: Math.max(0, stats.totalSurveys - stats.activeSurveys) },
  ];

  const COLORS = ['#008000', '#1565C0', '#6A1B9A', '#E65100'];

  return (
    <Box>
      <PageHeader
        title="Administrative Dashboard"
        subtitle="Live platform metrics, surveys status, and response reports overview."
      />

      {/* KPI Cards Grid */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <StatCard
            title="Total Users"
            value={stats.totalUsers}
            icon={<PeopleIcon />}
            color="primary"
            description="All platform accounts"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <StatCard
            title="Active Users"
            value={stats.activeUsers}
            icon={<PeopleIcon />}
            color="success"
            description="Active field staff / admins"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <StatCard
            title="Total Surveys"
            value={stats.totalSurveys}
            icon={<ChecklistIcon />}
            color="info"
            description="Created survey templates"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <StatCard
            title="Active Surveys"
            value={stats.activeSurveys}
            icon={<ChecklistIcon />}
            color="warning"
            description="Currently active templates"
          />
        </Grid>
        <Grid size={{ xs: 12, sm: 6, md: 4, lg: 2.4 }}>
          <StatCard
            title="Total Responses"
            value={stats.totalResponses}
            icon={<PollIcon />}
            color="secondary"
            description="Synced survey results"
          />
        </Grid>
      </Grid>

      {/* Charts & Activity Section */}
      <Grid container spacing={4}>
        {/* Chart Column */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Card sx={{ height: '100%', minHeight: 400 }}>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, fontFamily: 'Outfit' }}>
                System Activity Overview
              </Typography>
              <Box sx={{ width: '100%', height: 320 }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart
                    data={barChartData}
                    margin={{ top: 20, right: 30, left: 20, bottom: 5 }}
                  >
                    <CartesianGrid strokeDasharray="3 3" vertical={false} />
                    <XAxis dataKey="name" />
                    <YAxis />
                    <ChartTooltip />
                    <Legend />
                    <Bar dataKey="total" fill="#008000" radius={[4, 4, 0, 0]} name="Total Registered" />
                    <Bar dataKey="active" fill="#1565C0" radius={[4, 4, 0, 0]} name="Active / Engaged" />
                  </BarChart>
                </ResponsiveContainer>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Survey Distribution Pie */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Card sx={{ height: '100%', minHeight: 400 }}>
            <CardContent sx={{ p: 3, display: 'flex', flexDirection: 'column' }}>
              <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, fontFamily: 'Outfit' }}>
                Surveys Breakdown
              </Typography>
              <Box sx={{ width: '100%', height: 260, flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={pieChartData}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={80}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {pieChartData.map((_, index) => (
                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <ChartTooltip />
                    <Legend verticalAlign="bottom" height={36} />
                  </PieChart>
                </ResponsiveContainer>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Recent Responses List */}
        <Grid size={{ xs: 12 }}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h5" sx={{ mb: 3, fontWeight: 700, fontFamily: 'Outfit' }}>
                Recent Activity Logs
              </Typography>
              {loadingResponses ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
                  <CircularProgress size={30} />
                </Box>
              ) : !responsesData || responsesData.length === 0 ? (
                <Typography variant="body1" color="text.secondary" sx={{ py: 2 }}>
                  No recent responses recorded.
                </Typography>
              ) : (
                <List>
                  {responsesData.map((res: any, idx: number) => (
                    <React.Fragment key={res.id}>
                      <ListItem alignItems="flex-start" sx={{ px: 0, py: 2 }}>
                        <ListItemAvatar>
                          <Avatar sx={{ bgcolor: 'secondary.subtle', color: 'secondary.main' }}>
                            <PollIcon />
                          </Avatar>
                        </ListItemAvatar>
                        <ListItemText
                          primary={
                            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                              <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                                Survey Submissions — {res.survey?.title || 'Unknown Survey'}
                              </Typography>
                              <Typography variant="caption" color="text.secondary">
                                {new Date(res.deviceTimestamp || res.createdAt).toLocaleString()}
                              </Typography>
                            </Box>
                          }
                          secondary={
                            <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                              Submitted by{' '}
                              <Box component="span" sx={{ fontWeight: 600, color: 'text.primary' }}>
                                {res.submittedBy?.fullName || 'Anonymous enumerator'}
                              </Box>{' '}
                              ({res.submittedBy?.email || 'N/A'}) with {res.answers?.length || 0} answer(s).
                            </Typography>
                          }
                        />
                      </ListItem>
                      {idx < responsesData.length - 1 && <Divider component="li" />}
                    </React.Fragment>
                  ))}
                </List>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};
