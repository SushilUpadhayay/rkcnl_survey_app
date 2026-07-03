import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { apiClient } from '../../api/client';
import type { Survey, Category, SurveyStatus } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import type { Column } from '../../components/DataTable';
import {
  Box,
  Button,
  TextField,
  MenuItem,
  Chip,
  IconButton,
  Tooltip,
  Typography,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Visibility as ViewIcon,
  AssignmentTurnedIn as AssignmentIcon,
} from '@mui/icons-material';

export const SurveyListPage: React.FC = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  
  // Filters state
  const [search, setSearch] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [categoryFilter, setCategoryFilter] = useState<string>('all');

  // Deletion state
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [surveyToDelete, setSurveyToDelete] = useState<Survey | null>(null);
  const [errorAlert, setErrorAlert] = useState<string | null>(null);

  // Fetch categories for filter dropdown
  const { data: categoriesData } = useQuery({
    queryKey: ['categories-all-filters'],
    queryFn: async () => {
      const response = await apiClient.get('/categories?limit=100');
      return response.data.data || [];
    },
  });

  // Query surveys with paginated parameters
  const { data, isLoading } = useQuery({
    queryKey: ['surveys', page, rowsPerPage, search, statusFilter, categoryFilter],
    queryFn: async () => {
      const params: any = {
        page: page + 1,
        limit: rowsPerPage,
        search,
      };
      if (statusFilter !== 'all') {
        params.status = statusFilter;
      }
      if (categoryFilter !== 'all') {
        params.categoryId = categoryFilter;
      }

      const response = await apiClient.get('/surveys', { params });
      return response.data;
    },
  });

  // Delete survey mutation (soft-delete)
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiClient.delete(`/surveys/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['surveys'] });
      setDeleteConfirmOpen(false);
      setSurveyToDelete(null);
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to delete survey.');
      setDeleteConfirmOpen(false);
    },
  });

  const handleOpenDelete = (survey: Survey) => {
    setSurveyToDelete(survey);
    setErrorAlert(null);
    setDeleteConfirmOpen(true);
  };

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSearch(searchInput);
    setPage(0);
  };

  const handleSearchClear = () => {
    setSearchInput('');
    setSearch('');
    setPage(0);
  };

  const getStatusChip = (status: SurveyStatus) => {
    switch (status) {
      case 'Draft':
        return <Chip label="Draft" color="default" size="small" sx={{ fontWeight: 600 }} />;
      case 'Active':
        return <Chip label="Active" color="success" size="small" sx={{ fontWeight: 600 }} />;
      case 'Closed':
        return <Chip label="Closed" color="error" size="small" sx={{ fontWeight: 600 }} />;
      default:
        return <Chip label={status} size="small" />;
    }
  };

  const columns: Column<Survey>[] = [
    {
      id: 'title',
      label: 'Title',
      minWidth: 200,
      render: (val, row) => (
        <Box>
          <Typography sx={{ fontWeight: 600 }}>{val}</Typography>
          <Typography variant="caption" color="text.secondary" noWrap sx={{ display: 'block', maxWidth: 220 }}>
            {row.description || 'No description provided.'}
          </Typography>
        </Box>
      ),
    },
    {
      id: 'category',
      label: 'Category',
      minWidth: 150,
      render: (val) => val?.name || <Typography variant="body2" color="text.disabled">None</Typography>,
    },
    {
      id: 'status',
      label: 'Status',
      minWidth: 120,
      render: (val) => getStatusChip(val),
    },
    {
      id: 'responses',
      label: 'Responses',
      minWidth: 110,
      align: 'center',
      render: (_, row) => row._count?.responses || 0,
    },
    {
      id: 'assignments',
      label: 'Assigned To',
      minWidth: 110,
      align: 'center',
      render: (_, row) => row._count?.assignments || 0,
    },
    {
      id: 'createdAt',
      label: 'Created At',
      minWidth: 150,
      render: (val) => new Date(val).toLocaleDateString(),
    },
    {
      id: 'actions',
      label: 'Actions',
      minWidth: 180,
      align: 'right',
      render: (_, row) => (
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 0.5 }}>
          <Tooltip title="View Details / Live Preview">
            <IconButton color="info" onClick={() => navigate(`/surveys/${row.id}`)}>
              <ViewIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Edit Questions">
            <IconButton color="primary" onClick={() => navigate(`/surveys/${row.id}/edit`)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Manage Assignments">
            <IconButton color="secondary" onClick={() => navigate(`/assignments?surveyId=${row.id}`)}>
              <AssignmentIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Soft Delete">
            <IconButton color="error" onClick={() => handleOpenDelete(row)}>
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
        title="Survey Management"
        subtitle="Create, configure, and customize survey questionnaires for field enumeration."
        action={
          <Button
            variant="contained"
            color="primary"
            startIcon={<AddIcon />}
            onClick={() => navigate('/surveys/new')}
            sx={{ borderRadius: 2 }}
          >
            Create Survey
          </Button>
        }
      />

      {errorAlert && (
        <Alert severity="error" onClose={() => setErrorAlert(null)} sx={{ mb: 3, borderRadius: 2 }}>
          {errorAlert}
        </Alert>
      )}

      {/* Filter Toolbar */}
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, mb: 3, alignItems: 'center' }}>
        <Box component="form" onSubmit={handleSearchSubmit} sx={{ display: 'flex', gap: 1 }}>
          <TextField
            placeholder="Search surveys..."
            size="small"
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            sx={{ width: 220, bgcolor: 'background.paper', borderRadius: 1 }}
            slotProps={{
              input: {
                startAdornment: <SearchIcon color="action" fontSize="small" sx={{ mr: 1 }} />,
              },
            }}
          />
          <Button type="submit" variant="outlined" size="small">
            Search
          </Button>
          {search && (
            <Button onClick={handleSearchClear} size="small" color="secondary">
              Clear
            </Button>
          )}
        </Box>

        <TextField
          select
          label="Status"
          size="small"
          value={statusFilter}
          onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }}
          sx={{ minWidth: 120, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Statuses</MenuItem>
          <MenuItem value="Draft">Draft</MenuItem>
          <MenuItem value="Active">Active</MenuItem>
          <MenuItem value="Closed">Closed</MenuItem>
        </TextField>

        <TextField
          select
          label="Category"
          size="small"
          value={categoryFilter}
          onChange={(e) => { setCategoryFilter(e.target.value); setPage(0); }}
          sx={{ minWidth: 160, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Categories</MenuItem>
          {categoriesData?.map((cat: Category) => (
            <MenuItem key={cat.id} value={cat.id}>
              {cat.name}
            </MenuItem>
          ))}
        </TextField>
      </Box>

      {/* Surveys Table */}
      <DataTable
        columns={columns}
        rows={data?.data || []}
        count={data?.total || 0}
        page={page}
        rowsPerPage={rowsPerPage}
        loading={isLoading}
        onPageChange={setPage}
        onRowsPerPageChange={setRowsPerPage}
        emptyMessage="No surveys found. Click 'Create Survey' to design your first questionnaire."
      />

      {/* Delete Survey Confirmation Dialog */}
      <Dialog open={deleteConfirmOpen} onClose={() => setDeleteConfirmOpen(false)}>
        <DialogTitle sx={{ fontWeight: 600 }}>Soft Delete Survey?</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to soft delete the survey "{surveyToDelete?.title}"?
            This will hide the template from active lists and the mobile application,
            but all historical respondent submissions and records remain safely stored.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setDeleteConfirmOpen(false)} color="inherit">
            Cancel
          </Button>
          <Button
            onClick={() => surveyToDelete && deleteMutation.mutate(surveyToDelete.id)}
            color="error"
            variant="contained"
            disabled={deleteMutation.isPending}
          >
            {deleteMutation.isPending ? 'Deleting...' : 'Confirm Soft Delete'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
