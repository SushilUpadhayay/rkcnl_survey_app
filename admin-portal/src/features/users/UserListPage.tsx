import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { apiClient } from '../../api/client';
import type { User, Role } from '../../types';
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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Typography,
  Alert,
  Grid,
} from '@mui/material';
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Search as SearchIcon,
  Visibility as ViewIcon,
  Block as BlockIcon,
  CheckCircle as ActiveIcon,
} from '@mui/icons-material';

const userSchema = z.object({
  username: z.string().min(3, 'Username must be at least 3 characters'),
  email: z.string().email('Please enter a valid email address'),
  gender: z.string().optional().nullable(),
  dateOfBirth: z.string().optional().nullable(),
  phone: z.string().optional().nullable(),
  location: z.string().optional().nullable(),
  role: z.enum(['Admin', 'FieldStaff']),
});

type UserFormValues = z.infer<typeof userSchema>;

export const UserListPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Filters state
  const [search, setSearch] = useState('');
  const [searchInput, setSearchInput] = useState('');
  const [roleFilter, setRoleFilter] = useState<string>('all');
  const [statusFilter, setStatusFilter] = useState<string>('all');

  // Modal / Dialogue states
  const [openEditDialog, setOpenEditDialog] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [openDetailDialog, setOpenDetailDialog] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<User | null>(null);
  const [errorAlert, setErrorAlert] = useState<string | null>(null);

  const { register, handleSubmit, reset, setValue, formState: { errors } } = useForm<UserFormValues>({
    resolver: zodResolver(userSchema),
  });

  // Query users
  const { data, isLoading } = useQuery({
    queryKey: ['users', page, rowsPerPage, search, roleFilter, statusFilter],
    queryFn: async () => {
      const params: any = {
        page: page + 1,
        limit: rowsPerPage,
        search,
      };
      if (roleFilter !== 'all') {
        params.role = roleFilter;
      }
      if (statusFilter !== 'all') {
        params.isActive = statusFilter === 'active';
      }

      const response = await apiClient.get('/users', { params });
      return response.data;
    },
  });

  // Toggle user status mutation
  const toggleStatusMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiClient.patch(`/users/${id}/status`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to update user status.');
    },
  });

  // Edit User mutation
  const editUserMutation = useMutation({
    mutationFn: async (values: UserFormValues) => {
      if (!editingUser) return;
      return apiClient.put(`/users/${editingUser.id}`, values);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      setOpenEditDialog(false);
      setEditingUser(null);
      reset();
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to update user profile.');
    },
  });

  // Soft delete user mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiClient.delete(`/users/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      setDeleteConfirmOpen(false);
      setUserToDelete(null);
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to delete user.');
      setDeleteConfirmOpen(false);
    },
  });

  const handleOpenEdit = (user: User) => {
    setEditingUser(user);
    setValue('username', user.username);
    setValue('email', user.email);
    setValue('gender', user.gender);
    setValue('dateOfBirth', user.dateOfBirth);
    setValue('phone', user.phone);
    setValue('location', user.location);
    setValue('role', user.role);
    setErrorAlert(null);
    setOpenEditDialog(true);
  };

  const handleOpenDetail = (user: User) => {
    setSelectedUser(user);
    setOpenDetailDialog(true);
  };

  const handleOpenDelete = (user: User) => {
    setUserToDelete(user);
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

  const onSubmit = (values: UserFormValues) => {
    editUserMutation.mutate(values);
  };

  const columns: Column<User>[] = [
    { id: 'username', label: 'Username', minWidth: 150, render: (val) => <Typography sx={{ fontWeight: 600 }}>{val}</Typography> },
    { id: 'email', label: 'Email Address', minWidth: 200 },
    {
      id: 'role',
      label: 'Role',
      minWidth: 120,
      render: (val: Role) => (
        <Chip
          label={val}
          size="small"
          color={val === 'Admin' ? 'primary' : 'secondary'}
          sx={{ fontWeight: 600 }}
        />
      ),
    },
    {
      id: 'isActive',
      label: 'Status',
      minWidth: 100,
      render: (val) => (
        <Chip
          label={val ? 'Active' : 'Disabled'}
          size="small"
          color={val ? 'success' : 'default'}
          sx={{ fontWeight: 600 }}
        />
      ),
    },
    { id: 'location', label: 'Location', minWidth: 150, render: (val) => val || 'N/A' },
    {
      id: 'actions',
      label: 'Actions',
      minWidth: 180,
      align: 'right',
      render: (_, row) => (
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 0.5 }}>
          <Tooltip title="View Profile Details">
            <IconButton color="info" onClick={() => handleOpenDetail(row)}>
              <ViewIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Edit Profile">
            <IconButton color="primary" onClick={() => handleOpenEdit(row)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title={row.isActive ? 'Deactivate Account' : 'Activate Account'}>
            <IconButton
              color={row.isActive ? 'warning' : 'success'}
              onClick={() => toggleStatusMutation.mutate(row.id)}
            >
              {row.isActive ? <BlockIcon fontSize="small" /> : <ActiveIcon fontSize="small" />}
            </IconButton>
          </Tooltip>
          <Tooltip title="Delete (Soft)">
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
        title="User Management"
        subtitle="Manage surveyor profiles, permissions, roles, and administrative statuses."
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
            placeholder="Search username/email..."
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
          label="Role"
          size="small"
          value={roleFilter}
          onChange={(e) => { setRoleFilter(e.target.value); setPage(0); }}
          sx={{ minWidth: 120, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Roles</MenuItem>
          <MenuItem value="Admin">Admin</MenuItem>
          <MenuItem value="FieldStaff">FieldStaff</MenuItem>
        </TextField>

        <TextField
          select
          label="Account Status"
          size="small"
          value={statusFilter}
          onChange={(e) => { setStatusFilter(e.target.value); setPage(0); }}
          sx={{ minWidth: 140, bgcolor: 'background.paper', borderRadius: 1 }}
        >
          <MenuItem value="all">All Statuses</MenuItem>
          <MenuItem value="active">Active Only</MenuItem>
          <MenuItem value="disabled">Disabled Only</MenuItem>
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
        emptyMessage="No matching users found."
      />

      {/* Profile Detail Dialog */}
      <Dialog open={openDetailDialog} onClose={() => setOpenDetailDialog(false)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, fontFamily: 'Outfit' }}>Profile Details</DialogTitle>
        <DialogContent sx={{ pb: 3 }}>
          {selectedUser && (
            <Grid container spacing={2} sx={{ mt: 0.5 }}>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Username</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>{selectedUser.username}</Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Role</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>{selectedUser.role}</Typography>
              </Grid>
              <Grid size={12}>
                <Typography variant="caption" color="text.secondary">Email Address</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>{selectedUser.email}</Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Gender</Typography>
                <Typography variant="body2">{selectedUser.gender || 'Not specified'}</Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Date of Birth</Typography>
                <Typography variant="body2">{selectedUser.dateOfBirth || 'Not specified'}</Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Phone number</Typography>
                <Typography variant="body2">{selectedUser.phone || 'Not specified'}</Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Location</Typography>
                <Typography variant="body2">{selectedUser.location || 'Not specified'}</Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Status</Typography>
                <Typography variant="body2" sx={{ fontWeight: 600, color: selectedUser.isActive ? 'success.main' : 'text.disabled' }}>
                  {selectedUser.isActive ? 'Active' : 'Disabled'}
                </Typography>
              </Grid>
              <Grid size={6}>
                <Typography variant="caption" color="text.secondary">Created Date</Typography>
                <Typography variant="body2">{new Date(selectedUser.createdAt).toLocaleDateString()}</Typography>
              </Grid>
            </Grid>
          )}
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setOpenDetailDialog(false)} color="primary">
            Close
          </Button>
        </DialogActions>
      </Dialog>

      {/* Edit Profile Dialog */}
      <Dialog open={openEditDialog} onClose={() => setOpenEditDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, fontFamily: 'Outfit' }}>Edit User Profile</DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent>
            <Grid container spacing={2} sx={{ pt: 1 }}>
              <Grid size={6}>
                <TextField
                  {...register('username')}
                  label="Username"
                  fullWidth
                  required
                  error={!!errors.username}
                  helperText={errors.username?.message}
                />
              </Grid>
              <Grid size={6}>
                <TextField
                  {...register('role')}
                  select
                  label="Role"
                  fullWidth
                  required
                  defaultValue="FieldStaff"
                >
                  <MenuItem value="Admin">Admin</MenuItem>
                  <MenuItem value="FieldStaff">FieldStaff</MenuItem>
                </TextField>
              </Grid>
              <Grid size={12}>
                <TextField
                  {...register('email')}
                  label="Email"
                  fullWidth
                  required
                  error={!!errors.email}
                  helperText={errors.email?.message}
                />
              </Grid>
              <Grid size={6}>
                <TextField
                  {...register('phone')}
                  label="Phone Number"
                  fullWidth
                />
              </Grid>
              <Grid size={6}>
                <TextField
                  {...register('gender')}
                  label="Gender"
                  fullWidth
                  placeholder="e.g. Male, Female"
                />
              </Grid>
              <Grid size={6}>
                <TextField
                  {...register('dateOfBirth')}
                  label="Date of Birth"
                  fullWidth
                  placeholder="YYYY-MM-DD"
                />
              </Grid>
              <Grid size={6}>
                <TextField
                  {...register('location')}
                  label="Location"
                  fullWidth
                />
              </Grid>
            </Grid>
          </DialogContent>
          <DialogActions sx={{ px: 3, pb: 3 }}>
            <Button onClick={() => setOpenEditDialog(false)} color="inherit">
              Cancel
            </Button>
            <Button
              type="submit"
              variant="contained"
              color="primary"
              disabled={editUserMutation.isPending}
            >
              {editUserMutation.isPending ? 'Saving...' : 'Save Changes'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteConfirmOpen} onClose={() => setDeleteConfirmOpen(false)}>
        <DialogTitle sx={{ fontWeight: 600 }}>Soft Delete User?</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to soft delete the user "{userToDelete?.username}"?
            This will disable their account login and hide them from active lists.
            All historical survey assignments and response records remain intact.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setDeleteConfirmOpen(false)} color="inherit">
            Cancel
          </Button>
          <Button
            onClick={() => userToDelete && deleteMutation.mutate(userToDelete.id)}
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
