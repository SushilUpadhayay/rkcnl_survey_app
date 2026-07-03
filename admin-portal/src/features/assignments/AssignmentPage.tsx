import React, { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useSearchParams } from 'react-router-dom';
import { apiClient } from '../../api/client';
import type { SurveyAssignment, Survey, User } from '../../types';
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
  Alert,
  Tooltip,
  IconButton,
} from '@mui/material';
import {
  Add as AddIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';

export const AssignmentPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useSearchParams();
  const initialSurveyId = searchParams.get('surveyId') || 'all';

  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Filters state
  const [surveyFilter, setSurveyFilter] = useState<string>(initialSurveyId);
  const [userFilter, setUserFilter] = useState<string>('all');

  // Modal states
  const [openAssignDialog, setOpenAssignDialog] = useState(false);
  const [selectedSurveyId, setSelectedSurveyId] = useState('');
  const [selectedUserId, setSelectedUserId] = useState('');

  const [openUnassignDialog, setOpenUnassignDialog] = useState(false);
  const [assignmentToUnassign, setAssignmentToUnassign] = useState<SurveyAssignment | null>(null);

  const [errorAlert, setErrorAlert] = useState<string | null>(null);

  // Fetch all active surveys for dropdowns/filters
  const { data: surveys } = useQuery<Survey[]>({
    queryKey: ['active-surveys-all'],
    queryFn: async () => {
      const res = await apiClient.get('/surveys?limit=100&status=Active');
      return res.data.data || [];
    },
  });

  // Fetch all active FieldStaff for dropdowns/filters
  const { data: users } = useQuery<User[]>({
    queryKey: ['active-fieldstaff-all'],
    queryFn: async () => {
      const res = await apiClient.get('/users?limit=100&role=FieldStaff&isActive=true');
      return res.data.data || [];
    },
  });

  // Sync route query param change with local filter
  useEffect(() => {
    const sId = searchParams.get('surveyId');
    if (sId) {
      setSurveyFilter(sId);
    }
  }, [searchParams]);

  // Query assignments
  const { data, isLoading } = useQuery({
    queryKey: ['assignments', page, rowsPerPage, surveyFilter, userFilter],
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

      // Backend route GET /surveys/assignments
      const response = await apiClient.get('/surveys/assignments', { params });
      return response.data;
    },
  });

  // Assign survey mutation
  const assignMutation = useMutation({
    mutationFn: async (payload: { surveyId: string; userId: string }) => {
      return apiClient.post('/surveys/assign', payload);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assignments'] });
      setOpenAssignDialog(false);
      setSelectedSurveyId('');
      setSelectedUserId('');
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to assign survey.');
    },
  });

  // Unassign survey mutation
  const unassignMutation = useMutation({
    mutationFn: async (payload: { surveyId: string; userId: string }) => {
      // Backend route: DELETE /surveys/assign takes payload in body
      return apiClient.delete('/surveys/assign', { data: payload });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['assignments'] });
      setOpenUnassignDialog(false);
      setAssignmentToUnassign(null);
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to unassign survey.');
      setOpenUnassignDialog(false);
    },
  });

  const handleOpenAssign = () => {
    setErrorAlert(null);
    setSelectedSurveyId(surveyFilter !== 'all' ? surveyFilter : '');
    setSelectedUserId('');
    setOpenAssignDialog(true);
  };

  const handleOpenUnassign = (assignment: SurveyAssignment) => {
    setAssignmentToUnassign(assignment);
    setErrorAlert(null);
    setOpenUnassignDialog(true);
  };

  const handleConfirmAssign = () => {
    if (!selectedSurveyId || !selectedUserId) {
      setErrorAlert('Please select both a survey and a user.');
      return;
    }
    assignMutation.mutate({ surveyId: selectedSurveyId, userId: selectedUserId });
  };

  const columns: Column<SurveyAssignment>[] = [
    {
      id: 'survey',
      label: 'Survey Title',
      minWidth: 250,
      render: (val) => <Typography sx={{ fontWeight: 600 }}>{val?.title || 'Unknown Survey'}</Typography>,
    },
    {
      id: 'user',
      label: 'Assigned Surveyor',
      minWidth: 200,
      render: (val) => (
        <Box>
          <Typography variant="body2" sx={{ fontWeight: 500 }}>
            {val?.username || 'Unknown User'}
          </Typography>
          <Typography variant="caption" color="text.secondary">
            {val?.email || 'N/A'}
          </Typography>
        </Box>
      ),
    },
    {
      id: 'location',
      label: 'Surveyor Location',
      minWidth: 150,
      render: (_, row) => row.user?.location || 'N/A',
    },
    {
      id: 'createdAt',
      label: 'Assignment Date',
      minWidth: 150,
      render: (val) => new Date(val).toLocaleDateString(),
    },
    {
      id: 'actions',
      label: 'Actions',
      minWidth: 100,
      align: 'right',
      render: (_, row) => (
        <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
          <Tooltip title="Remove Assignment">
            <IconButton color="error" onClick={() => handleOpenUnassign(row)}>
              <DeleteIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  return (
    <Box>
      <PageHeader
        title="Survey Assignments"
        subtitle="Allocate active questionnaires to specific FieldStaff surveyors for collection."
        action={
          <Button
            variant="contained"
            color="primary"
            startIcon={<AddIcon />}
            onClick={handleOpenAssign}
            sx={{ borderRadius: 2 }}
          >
            Assign Survey
          </Button>
        }
      />

      {errorAlert && (
        <Alert severity="error" onClose={() => setErrorAlert(null)} sx={{ mb: 3, borderRadius: 2 }}>
          {errorAlert}
        </Alert>
      )}

      {/* Filters Toolbar */}
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, mb: 3, alignItems: 'center' }}>
        <TextField
          select
          label="Filter by Survey"
          size="small"
          value={surveyFilter}
          onChange={(e) => {
            const val = e.target.value;
            setSurveyFilter(val);
            setPage(0);
            if (val === 'all') {
              searchParams.delete('surveyId');
            } else {
              searchParams.set('surveyId', val);
            }
            setSearchParams(searchParams);
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
          label="Filter by User"
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
              {user.username} ({user.email})
            </MenuItem>
          ))}
        </TextField>
      </Box>

      {/* Assignments list table */}
      <DataTable
        columns={columns}
        rows={data?.data || []}
        count={data?.total || 0}
        page={page}
        rowsPerPage={rowsPerPage}
        loading={isLoading}
        onPageChange={setPage}
        onRowsPerPageChange={setRowsPerPage}
        emptyMessage="No active assignments match your filters. Click 'Assign Survey' to start."
      />

      {/* Assign Survey Dialog Modal */}
      <Dialog open={openAssignDialog} onClose={() => setOpenAssignDialog(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, fontFamily: 'Outfit' }}>
          Assign Survey to Surveyor
        </DialogTitle>
        <DialogContent sx={{ pt: 1 }}>
          <TextField
            select
            label="Select Active Survey"
            fullWidth
            required
            margin="normal"
            value={selectedSurveyId}
            onChange={(e) => setSelectedSurveyId(e.target.value)}
          >
            {surveys?.map((s) => (
              <MenuItem key={s.id} value={s.id}>
                {s.title}
              </MenuItem>
            ))}
            {(!surveys || surveys.length === 0) && (
              <MenuItem disabled value="">No active surveys available</MenuItem>
            )}
          </TextField>

          <TextField
            select
            label="Select Surveyor"
            fullWidth
            required
            margin="normal"
            value={selectedUserId}
            onChange={(e) => setSelectedUserId(e.target.value)}
          >
            {users?.map((u) => (
              <MenuItem key={u.id} value={u.id}>
                {u.username} ({u.location || 'No location'})
              </MenuItem>
            ))}
            {(!users || users.length === 0) && (
              <MenuItem disabled value="">No active surveyors available</MenuItem>
            )}
          </TextField>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setOpenAssignDialog(false)} color="inherit">
            Cancel
          </Button>
          <Button
            variant="contained"
            color="primary"
            onClick={handleConfirmAssign}
            disabled={assignMutation.isPending}
          >
            {assignMutation.isPending ? 'Assigning...' : 'Assign'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Unassign Confirmation Dialog */}
      <Dialog open={openUnassignDialog} onClose={() => setOpenUnassignDialog(false)}>
        <DialogTitle sx={{ fontWeight: 600 }}>Remove Assignment?</DialogTitle>
        <DialogContent>
          {assignmentToUnassign && (
            <Typography>
              Are you sure you want to unassign survey "{assignmentToUnassign.survey?.title}" 
              from surveyor "{assignmentToUnassign.user?.username}"? 
              They will no longer be able to submit responses for this survey on their mobile device.
            </Typography>
          )}
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setOpenUnassignDialog(false)} color="inherit">
            Cancel
          </Button>
          <Button
            onClick={() =>
              assignmentToUnassign &&
              unassignMutation.mutate({
                surveyId: assignmentToUnassign.surveyId,
                userId: assignmentToUnassign.userId,
              })
            }
            color="error"
            variant="contained"
            disabled={unassignMutation.isPending}
          >
            {unassignMutation.isPending ? 'Removing...' : 'Confirm Remove'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
