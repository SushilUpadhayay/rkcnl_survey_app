import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { apiClient } from '../../api/client';
import type { Category } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import { DataTable } from '../../components/DataTable';
import type { Column } from '../../components/DataTable';
import {
  Box,
  Button,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Typography,
  Alert,
  Tooltip,
} from '@mui/material';
import { Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon, Search as SearchIcon } from '@mui/icons-material';

const categorySchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  description: z.string().optional(),
});

type CategoryFormValues = z.infer<typeof categorySchema>;

export const CategoryListPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);
  const [search, setSearch] = useState('');
  const [searchInput, setSearchInput] = useState('');

  // Dialog states
  const [openDialog, setOpenDialog] = useState(false);
  const [editingCategory, setEditingCategory] = useState<Category | null>(null);
  const [deleteConfirmOpen, setDeleteConfirmOpen] = useState(false);
  const [categoryToDelete, setCategoryToDelete] = useState<Category | null>(null);
  const [errorAlert, setErrorAlert] = useState<string | null>(null);

  const { register, handleSubmit, reset, setValue, formState: { errors } } = useForm<CategoryFormValues>({
    resolver: zodResolver(categorySchema),
    defaultValues: { name: '', description: '' },
  });

  // Query categories
  const { data, isLoading } = useQuery({
    queryKey: ['categories', page, rowsPerPage, search],
    queryFn: async () => {
      const response = await apiClient.get('/categories', {
        params: {
          page: page + 1,
          limit: rowsPerPage,
          search,
        },
      });
      return response.data;
    },
  });

  // Create/Edit Mutation
  const saveMutation = useMutation({
    mutationFn: async (values: CategoryFormValues) => {
      if (editingCategory) {
        return apiClient.put(`/categories/${editingCategory.id}`, values);
      } else {
        return apiClient.post('/categories', values);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] });
      handleCloseDialog();
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to save category.');
    },
  });

  // Delete Mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      return apiClient.delete(`/categories/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['categories'] });
      setDeleteConfirmOpen(false);
      setCategoryToDelete(null);
    },
    onError: (err: any) => {
      setErrorAlert(err.response?.data?.message || 'Failed to delete category.');
      setDeleteConfirmOpen(false);
    },
  });

  const handleOpenCreate = () => {
    setEditingCategory(null);
    reset({ name: '', description: '' });
    setErrorAlert(null);
    setOpenDialog(true);
  };

  const handleOpenEdit = (category: Category) => {
    setEditingCategory(category);
    setValue('name', category.name);
    setValue('description', category.description || '');
    setErrorAlert(null);
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingCategory(null);
    reset();
  };

  const handleOpenDelete = (category: Category) => {
    setCategoryToDelete(category);
    setErrorAlert(null);
    setDeleteConfirmOpen(true);
  };

  const onSubmit = (values: CategoryFormValues) => {
    saveMutation.mutate(values);
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

  const columns: Column<Category>[] = [
    { id: 'name', label: 'Name', minWidth: 200, render: (val) => <Typography sx={{ fontWeight: 600 }}>{val}</Typography> },
    { id: 'description', label: 'Description', minWidth: 300 },
    { id: '_count', label: 'Surveys Linked', minWidth: 150, align: 'center', render: (val) => val?.surveys || 0 },
    {
      id: 'actions',
      label: 'Actions',
      minWidth: 120,
      align: 'right',
      render: (_, row) => (
        <Box sx={{ display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
          <Tooltip title="Edit Category">
            <IconButton color="primary" onClick={() => handleOpenEdit(row)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Delete Category">
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
        title="Category Management"
        subtitle="Organize and group survey templates by agriculture domains or modules."
        action={
          <Button
            variant="contained"
            color="primary"
            startIcon={<AddIcon />}
            onClick={handleOpenCreate}
            sx={{ borderRadius: 2 }}
          >
            Create Category
          </Button>
        }
      />

      {errorAlert && (
        <Alert severity="error" onClose={() => setErrorAlert(null)} sx={{ mb: 3, borderRadius: 2 }}>
          {errorAlert}
        </Alert>
      )}

      {/* Filter Header */}
      <Box component="form" onSubmit={handleSearchSubmit} sx={{ display: 'flex', gap: 2, mb: 3 }}>
        <TextField
          placeholder="Search by name..."
          size="small"
          value={searchInput}
          onChange={(e) => setSearchInput(e.target.value)}
          sx={{ maxWidth: 300, bgcolor: 'background.paper', borderRadius: 1 }}
          slotProps={{
            input: {
              startAdornment: <SearchIcon color="action" fontSize="small" sx={{ mr: 1 }} />,
            },
          }}
        />
        <Button type="submit" variant="outlined" size="small" sx={{ borderRadius: 1.5 }}>
          Search
        </Button>
        {search && (
          <Button onClick={handleSearchClear} variant="text" size="small" color="secondary">
            Clear Search
          </Button>
        )}
      </Box>

      {/* Reusable Data Table */}
      <DataTable
        columns={columns}
        rows={data?.data || []}
        count={data?.total || 0}
        page={page}
        rowsPerPage={rowsPerPage}
        loading={isLoading}
        onPageChange={setPage}
        onRowsPerPageChange={setRowsPerPage}
        emptyMessage="No categories found. Click 'Create Category' to add one."
      />

      {/* Create / Edit Dialog */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, fontFamily: 'Outfit' }}>
          {editingCategory ? 'Edit Category' : 'Create New Category'}
        </DialogTitle>
        <form onSubmit={handleSubmit(onSubmit)}>
          <DialogContent sx={{ pt: 1 }}>
            <TextField
              {...register('name')}
              label="Category Name"
              fullWidth
              required
              margin="normal"
              error={!!errors.name}
              helperText={errors.name?.message}
              placeholder="e.g. Soil & Fertilizer"
            />
            <TextField
              {...register('description')}
              label="Description"
              fullWidth
              multiline
              rows={3}
              margin="normal"
              placeholder="Brief description of the category..."
            />
          </DialogContent>
          <DialogActions sx={{ px: 3, pb: 3 }}>
            <Button onClick={handleCloseDialog} color="inherit">
              Cancel
            </Button>
            <Button
              type="submit"
              variant="contained"
              color="primary"
              disabled={saveMutation.isPending}
            >
              {saveMutation.isPending ? 'Saving...' : editingCategory ? 'Save Changes' : 'Create Category'}
            </Button>
          </DialogActions>
        </form>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={deleteConfirmOpen} onClose={() => setDeleteConfirmOpen(false)}>
        <DialogTitle sx={{ fontWeight: 600 }}>Delete Category?</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to permanently delete category "{categoryToDelete?.name}"?
            This action cannot be undone.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setDeleteConfirmOpen(false)} color="inherit">
            Cancel
          </Button>
          <Button
            onClick={() => categoryToDelete && deleteMutation.mutate(categoryToDelete.id)}
            color="error"
            variant="contained"
            disabled={deleteMutation.isPending}
          >
            {deleteMutation.isPending ? 'Deleting...' : 'Delete Category'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
