import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { apiClient } from '../../api/client';
import type { Response, Survey, User } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import type { Column } from '../../components/DataTable';
import {
  Box,
  Button,
  TextField,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Typography,
  Grid,
  Divider,
  Paper,
  IconButton,
  Tooltip,
  Card,
  CardContent,
  Alert,
} from '@mui/material';
import {
  Visibility as ViewIcon,
  LocationOn as LocationIcon,
  PhotoCamera as PhotoIcon,
} from '@mui/icons-material';

export const ResponseListPage: React.FC = () => {
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Filters state
  const [surveyFilter, setSurveyFilter] = useState<string>('all');
  const [userFilter, setUserFilter] = useState<string>('all');

  // Detail Modal state
  const [openDetailDialog, setOpenDetailDialog] = useState(false);
  const [selectedResponse, setSelectedResponse] = useState<Response | null>(null);

  // Fetch surveys for filter
  const { data: surveys } = useQuery<Survey[]>({
    queryKey: ['surveys-responses-filter'],
    queryFn: async () => {
      const res = await apiClient.get('/surveys?limit=100');
      return res.data.data || [];
    },
  });

  // Fetch users for filter
  const { data: users } = useQuery<User[]>({
    queryKey: ['users-responses-filter'],
    queryFn: async () => {
      const res = await apiClient.get('/users?limit=100&role=FieldStaff');
      return res.data.data || [];
    },
  });

  // Query responses
  const { data, isLoading } = useQuery({
    queryKey: ['responses', page, rowsPerPage, surveyFilter, userFilter],
    queryFn: async () => {
      const params: any = {
        page: page + 1,
        limit: rowsPerPage,
      };
      if (surveyFilter !== 'all') {
        params.surveyId = surveyFilter;
      }
      if (userFilter !== 'all') {
        params.userId = userFilter;
      }

      const response = await apiClient.get('/responses', { params });
      return response.data;
    },
  });

  const handleOpenDetail = (response: Response) => {
    setSelectedResponse(response);
    setOpenDetailDialog(true);
  };

  const columns: Column<Response>[] = [
    {
      id: 'survey',
      label: 'Survey Title',
      minWidth: 200,
      render: (val) => <Typography sx={{ fontWeight: 600 }}>{val?.title || 'Unknown Survey'}</Typography>,
    },
    {
      id: 'submittedBy',
      label: 'Submitted By',
      minWidth: 150,
      render: (val) => val?.username || 'Unknown surveyor',
    },
    {
      id: 'answers',
      label: 'Total Answers',
      minWidth: 120,
      align: 'center',
      render: (val) => val?.length || 0,
    },
    {
      id: 'deviceTimestamp',
      label: 'Collected Time',
      minWidth: 180,
      render: (val) => new Date(val).toLocaleString(),
    },
    {
      id: 'location',
      label: 'GPS Coordinates',
      minWidth: 150,
      render: (_, row) =>
        row.latitude && row.longitude ? (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
            <LocationIcon fontSize="inherit" color="primary" />
            <Typography variant="body2">
              {row.latitude.toFixed(4)}, {row.longitude.toFixed(4)}
            </Typography>
          </Box>
        ) : (
          <Typography variant="body2" color="text.disabled">
            N/A
          </Typography>
        ),
    },
    {
      id: 'actions',
      label: 'Actions',
      minWidth: 100,
      align: 'right',
      render: (_, row) => (
        <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
          <Tooltip title="View Submissions Details">
            <IconButton color="primary" onClick={() => handleOpenDetail(row)}>
              <ViewIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const renderValue = (val: any) => {
    if (val === null || val === undefined) return 'N/A';
    if (Array.isArray(val)) return val.join(', ');
    if (typeof val === 'object') return JSON.stringify(val);
    return String(val);
  };

  return (
    <Box>
      <PageHeader
        title="Survey Responses"
        subtitle="Monitor, inspect, and analyze incoming real-time field data submissions."
      />

      {/* Filter Toolbar */}
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, mb: 3, alignItems: 'center' }}>
        <TextField
          select
          label="Filter by Survey"
          size="small"
          value={surveyFilter}
          onChange={(e) => {
            setSurveyFilter(e.target.value);
            setPage(0);
          }}
          sx={{ minWidth: 220, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Surveys</MenuItem>
          {surveys?.map((survey) => (
            <MenuItem key={survey.id} value={survey.id}>
              {survey.title}
            </MenuItem>
          ))}
        </TextField>

        <TextField
          select
          label="Filter by Surveyor"
          size="small"
          value={userFilter}
          onChange={(e) => {
            setUserFilter(e.target.value);
            setPage(0);
          }}
          sx={{ minWidth: 200, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Surveyors</MenuItem>
          {users?.map((user) => (
            <MenuItem key={user.id} value={user.id}>
              {user.username}
            </MenuItem>
          ))}
        </TextField>
      </Box>

      {/* Data Table */}
      <DataTable
        columns={columns}
        rows={data?.data || []}
        count={data?.total || 0}
        page={page}
        rowsPerPage={rowsPerPage}
        loading={isLoading}
        onPageChange={setPage}
        onRowsPerPageChange={setRowsPerPage}
        emptyMessage="No response submissions found matching filters."
      />

      {/* Detailed Response Dialog Modal */}
      <Dialog open={openDetailDialog} onClose={() => setOpenDetailDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, fontFamily: 'Outfit' }}>
          Response Detail View
        </DialogTitle>
        <DialogContent sx={{ pb: 3 }}>
          {selectedResponse && (
            <Box sx={{ pt: 1 }}>
              {/* Metadata details */}
              <Grid container spacing={3} sx={{ mb: 3 }}>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Paper sx={{ p: 2, bgcolor: 'background.subtle' }}>
                    <Typography variant="caption" color="text.secondary">Survey Template</Typography>
                    <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>
                      {selectedResponse.survey?.title || 'Unknown Survey'}
                    </Typography>
                    {selectedResponse.survey?.category && (
                      <Typography variant="caption" sx={{ color: 'primary.main', fontWeight: 600 }}>
                        Category: {selectedResponse.survey.category.name}
                      </Typography>
                    )}
                  </Paper>
                </Grid>
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Paper sx={{ p: 2, bgcolor: 'background.subtle' }}>
                    <Typography variant="caption" color="text.secondary">Submitted By</Typography>
                    <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>
                      {selectedResponse.submittedBy?.username || 'Unknown surveyor'}
                    </Typography>
                    <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
                      Time Collected: {new Date(selectedResponse.deviceTimestamp).toLocaleString()}
                    </Typography>
                  </Paper>
                </Grid>

                {/* GPS and Location details */}
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Paper sx={{ p: 2, bgcolor: 'background.subtle', display: 'flex', alignItems: 'center', gap: 2 }}>
                    <LocationIcon color="primary" sx={{ fontSize: 32 }} />
                    <Box>
                      <Typography variant="caption" color="text.secondary">GPS Location</Typography>
                      {selectedResponse.latitude && selectedResponse.longitude ? (
                        <Typography variant="body2" sx={{ fontWeight: 600 }}>
                          Lat: {selectedResponse.latitude.toFixed(6)}, Lng: {selectedResponse.longitude.toFixed(6)}
                        </Typography>
                      ) : (
                        <Typography variant="body2">Coordinates not captured</Typography>
                      )}
                    </Box>
                  </Paper>
                </Grid>

                {/* Personal Notes details */}
                <Grid size={{ xs: 12, sm: 6 }}>
                  <Paper sx={{ p: 2, bgcolor: 'background.subtle' }}>
                    <Typography variant="caption" color="text.secondary">Enumerator Notes</Typography>
                    <Typography variant="body2" sx={{ fontStyle: 'italic' }}>
                      {selectedResponse.personalNotes || 'No notes added'}
                    </Typography>
                  </Paper>
                </Grid>
              </Grid>

              {/* Photos Gallery */}
              {selectedResponse.photos && selectedResponse.photos.length > 0 && (
                <Box sx={{ mb: 3 }}>
                  <Typography variant="subtitle2" sx={{ fontWeight: 600, mb: 1.5, display: 'flex', alignItems: 'center', gap: 1 }}>
                    <PhotoIcon fontSize="small" color="primary" />
                    Attached Media Photos ({selectedResponse.photos.length})
                  </Typography>
                  <Grid container spacing={2}>
                    {selectedResponse.photos.map((photo, pIdx) => (
                      <Grid size={{ xs: 6, sm: 4, md: 3 }} key={pIdx}>
                        <Paper
                          variant="outlined"
                          sx={{
                            p: 0.5,
                            borderRadius: 2,
                            overflow: 'hidden',
                            display: 'flex',
                            justifyContent: 'center',
                            alignItems: 'center',
                            height: 120,
                            bgcolor: 'grey.200',
                          }}
                        >
                          <img
                            src={photo.startsWith('data:image') ? photo : `http://localhost:3000${photo}`}
                            alt={`Attachment ${pIdx + 1}`}
                            style={{
                              maxWidth: '100%',
                              maxHeight: '100%',
                              objectFit: 'cover',
                              borderRadius: 4,
                            }}
                            onError={(e) => {
                              (e.target as HTMLImageElement).src = 'https://placehold.co/150?text=Photo';
                            }}
                          />
                        </Paper>
                      </Grid>
                    ))}
                  </Grid>
                  <Divider sx={{ my: 3 }} />
                </Box>
              )}

              {/* Answers details */}
              <Typography variant="h6" sx={{ fontWeight: 700, mb: 2, fontFamily: 'Outfit' }}>
                Respondent Answers
              </Typography>

              {(!selectedResponse.answers || selectedResponse.answers.length === 0) ? (
                <Alert severity="warning">This response contains no answer data.</Alert>
              ) : (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                  {selectedResponse.answers.map((ans, aIdx) => (
                    <Card key={aIdx} variant="outlined" sx={{ borderRadius: 2 }}>
                      <CardContent sx={{ p: 2 }}>
                        <Typography variant="subtitle2" color="primary.main" sx={{ fontWeight: 700, mb: 1 }}>
                          Q. {ans.questionText}
                        </Typography>
                        <Typography variant="body2" sx={{ fontWeight: 600, color: 'text.primary', pl: 2, borderLeft: '3px solid', borderColor: 'secondary.main' }}>
                          Ans: {renderValue(ans.value)}
                        </Typography>
                      </CardContent>
                    </Card>
                  ))}
                </Box>
              )}
            </Box>
          )}
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setOpenDetailDialog(false)} color="primary" variant="contained">
            Close
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
