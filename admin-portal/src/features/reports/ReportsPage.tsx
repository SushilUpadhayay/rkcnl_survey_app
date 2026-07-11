import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../../api/client';
import type { Survey, Response } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Grid,
  Button,
  TextField,
  MenuItem,
  CircularProgress,
  Alert,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Divider,
} from '@mui/material';
import {
  Download as DownloadIcon,
  BarChart as BarChartIcon,
  Group as GroupIcon,
  Timeline as TimelineIcon,
} from '@mui/icons-material';

export const ReportsPage: React.FC = () => {
  const [selectedSurveyId, setSelectedSurveyId] = useState<string>('all');
  const [exporting, setExporting] = useState(false);

  // Fetch all surveys for dropdown selection
  const { data: surveys, isLoading: loadingSurveys } = useQuery<Survey[]>({
    queryKey: ['surveys-reports'],
    queryFn: async () => {
      const res = await apiClient.get('/surveys?limit=100');
      return res.data.data || [];
    },
  });

  // Fetch response aggregates/stats
  const { data: reportData, isLoading: loadingReport, error } = useQuery({
    queryKey: ['reports-data', selectedSurveyId],
    queryFn: async () => {
      const params = selectedSurveyId !== 'all' ? { surveyId: selectedSurveyId } : {};

      // Fetch responses to compile statistics
      const resResponses = await apiClient.get('/responses?limit=1000', { params });
      const responsesList: Response[] = resResponses.data.data || [];

      // Compile stats
      const userSubmissions: Record<string, { fullName: string; email: string; count: number }> = {};
      const surveySubmissions: Record<string, { title: string; count: number }> = {};
      const dateSubmissions: Record<string, number> = {};

      responsesList.forEach((res) => {
        const fullName = res.submittedBy?.fullName || 'Unknown surveyor';
        const email = res.submittedBy?.email || 'N/A';
        const userId = res.submittedById;
        const surveyTitle = res.survey?.title || 'Unknown Survey';
        const surveyId = res.surveyId;
        const dateStr = new Date(res.deviceTimestamp || res.createdAt).toLocaleDateString();

        if (!userSubmissions[userId]) {
          userSubmissions[userId] = { fullName, email, count: 0 };
        }
        userSubmissions[userId].count += 1;

        if (!surveySubmissions[surveyId]) {
          surveySubmissions[surveyId] = { title: surveyTitle, count: 0 };
        }
        surveySubmissions[surveyId].count += 1;

        dateSubmissions[dateStr] = (dateSubmissions[dateStr] || 0) + 1;
      });

      return {
        responsesList,
        userSubmissions: Object.values(userSubmissions).sort((a, b) => b.count - a.count),
        surveySubmissions: Object.values(surveySubmissions).sort((a, b) => b.count - a.count),
        dateSubmissions: Object.entries(dateSubmissions).map(([date, count]) => ({ date, count })),
      };
    },
  });

  const handleExportCSV = async () => {
    if (!reportData?.responsesList || reportData.responsesList.length === 0) {
      alert('No data available to export.');
      return;
    }

    setExporting(true);
    try {
      const headers = [
        'Response ID',
        'Survey Title',
        'Surveyor Name',
        'Surveyor Email',
        'Device Timestamp',
        'Latitude',
        'Longitude',
        'Personal Notes',
        'Question & Answer Details',
      ];

      const rows = reportData.responsesList.map((res) => {
        const qaFlattened = res.answers
          ?.map((ans) => `[Q: ${ans.questionText} -> A: ${JSON.stringify(ans.value)}]`)
          .join(' | ') || '';

        return [
          res.id,
          res.survey?.title || 'N/A',
          res.submittedBy?.fullName || 'N/A',
          res.submittedBy?.email || 'N/A',
          res.deviceTimestamp,
          res.latitude || 'N/A',
          res.longitude || 'N/A',
          `"${(res.personalNotes || '').replace(/"/g, '""')}"`,
          `"${qaFlattened.replace(/"/g, '""')}"`,
        ];
      });

      const csvContent =
        'data:text/csv;charset=utf-8,' +
        [headers.join(','), ...rows.map((row) => row.join(','))].join('\n');

      const encodedUri = encodeURI(csvContent);
      const link = document.createElement('a');
      link.setAttribute('href', encodedUri);

      const fileName = `RKCNL_Survey_Report_${
        selectedSurveyId !== 'all'
          ? (surveys?.find((s) => s.id === selectedSurveyId)?.title || 'Survey').replace(/\s+/g, '_')
          : 'All'
      }_${new Date().toISOString().split('T')[0]}.csv`;

      link.setAttribute('download', fileName);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } catch (err) {
      console.error('CSV Export failed:', err);
      alert('Failed to generate CSV export.');
    } finally {
      setExporting(false);
    }
  };

  if (loadingReport || loadingSurveys) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
        <CircularProgress size={50} />
      </Box>
    );
  }

  if (error) {
    return (
      <Box sx={{ p: 2 }}>
        <Alert severity="error">Failed to compile system reports. Please check connectivity.</Alert>
      </Box>
    );
  }

  return (
    <Box>
      <PageHeader
        title="Reporting & Export"
        subtitle="Download raw survey response records and view surveyor submission frequencies."
        action={
          <Button
            variant="contained"
            color="primary"
            startIcon={<DownloadIcon />}
            onClick={handleExportCSV}
            disabled={exporting || !reportData?.responsesList?.length}
            sx={{ borderRadius: 2 }}
          >
            {exporting ? 'Exporting...' : 'Export to CSV (Excel)'}
          </Button>
        }
      />

      {/* Filter toolbar */}
      <Box sx={{ display: 'flex', gap: 2, mb: 4, alignItems: 'center' }}>
        <TextField
          select
          label="Scope Survey Report"
          size="small"
          value={selectedSurveyId}
          onChange={(e) => setSelectedSurveyId(e.target.value)}
          sx={{ minWidth: 260, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Surveys Combined</MenuItem>
          {surveys?.map((s) => (
            <MenuItem key={s.id} value={s.id}>
              {s.title}
            </MenuItem>
          ))}
        </TextField>
      </Box>

      {/* Summary KPI grid */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid size={{ xs: 12, sm: 4 }}>
          <Card>
            <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2, p: 3 }}>
              <Paper sx={{ bgcolor: 'primary.subtle', color: 'primary.main', p: 1.5, borderRadius: 2 }}>
                <TimelineIcon fontSize="large" />
              </Paper>
              <Box>
                <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 600, textTransform: 'uppercase' }}>
                  Total Responses Scoped
                </Typography>
                <Typography variant="h4" sx={{ fontWeight: 800, fontFamily: 'Outfit' }}>
                  {reportData?.responsesList?.length || 0}
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid size={{ xs: 12, sm: 4 }}>
          <Card>
            <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2, p: 3 }}>
              <Paper sx={{ bgcolor: 'secondary.subtle', color: 'secondary.main', p: 1.5, borderRadius: 2 }}>
                <GroupIcon fontSize="large" />
              </Paper>
              <Box>
                <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 600, textTransform: 'uppercase' }}>
                  Unique Surveyors
                </Typography>
                <Typography variant="h4" sx={{ fontWeight: 800, fontFamily: 'Outfit' }}>
                  {reportData?.userSubmissions?.length || 0}
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid size={{ xs: 12, sm: 4 }}>
          <Card>
            <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2, p: 3 }}>
              <Paper sx={{ bgcolor: 'warning.subtle', color: 'warning.main', p: 1.5, borderRadius: 2 }}>
                <BarChartIcon fontSize="large" />
              </Paper>
              <Box>
                <Typography variant="caption" color="text.secondary" sx={{ fontWeight: 600, textTransform: 'uppercase' }}>
                  Unique Questionnaires
                </Typography>
                <Typography variant="h4" sx={{ fontWeight: 800, fontFamily: 'Outfit' }}>
                  {reportData?.surveySubmissions?.length || 0}
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Reports Tables Grid */}
      <Grid container spacing={4}>
        {/* User Activity Leaderboard */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Card sx={{ height: '100%' }}>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ mb: 2, fontWeight: 700, fontFamily: 'Outfit' }}>
                Surveyor Sync Frequencies
              </Typography>
              <Divider sx={{ mb: 2 }} />

              <TableContainer component={Box} sx={{ maxHeight: 350 }}>
                <Table size="small" stickyHeader>
                  <TableHead>
                    <TableRow>
                      <TableCell sx={{ fontWeight: 600 }}>Surveyor</TableCell>
                      <TableCell sx={{ fontWeight: 600 }}>Email</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 600 }}>Synced Submissions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {reportData?.userSubmissions?.map((item: any, idx: number) => (
                      <TableRow key={idx} hover>
                        <TableCell sx={{ fontWeight: 500 }}>{item.fullName}</TableCell>
                        <TableCell>{item.email}</TableCell>
                        <TableCell align="right" sx={{ fontWeight: 600, color: 'primary.main' }}>
                          {item.count}
                        </TableCell>
                      </TableRow>
                    ))}
                    {(!reportData?.userSubmissions || reportData.userSubmissions.length === 0) && (
                      <TableRow>
                        <TableCell colSpan={3} align="center" sx={{ py: 3, color: 'text.secondary' }}>
                          No submissions recorded.
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* Survey Performance Breakdown */}
        <Grid size={{ xs: 12, md: 6 }}>
          <Card sx={{ height: '100%' }}>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ mb: 2, fontWeight: 700, fontFamily: 'Outfit' }}>
                Response Counts by Survey Template
              </Typography>
              <Divider sx={{ mb: 2 }} />

              <TableContainer component={Box} sx={{ maxHeight: 350 }}>
                <Table size="small" stickyHeader>
                  <TableHead>
                    <TableRow>
                      <TableCell sx={{ fontWeight: 600 }}>Survey Title</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 600 }}>Total Responses</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {reportData?.surveySubmissions?.map((item: any, idx: number) => (
                      <TableRow key={idx} hover>
                        <TableCell sx={{ fontWeight: 500 }}>{item.title}</TableCell>
                        <TableCell align="right" sx={{ fontWeight: 600, color: 'secondary.main' }}>
                          {item.count}
                        </TableCell>
                      </TableRow>
                    ))}
                    {(!reportData?.surveySubmissions || reportData.surveySubmissions.length === 0) && (
                      <TableRow>
                        <TableCell colSpan={2} align="center" sx={{ py: 3, color: 'text.secondary' }}>
                          No submissions recorded.
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};
