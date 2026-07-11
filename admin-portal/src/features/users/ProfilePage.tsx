import React, { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuth } from '../auth/AuthContext';
import { apiClient } from '../../api/client';
import { PageHeader } from '../../components/PageHeader';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Grid,
  TextField,
  Button,
  Alert,
  Divider,
  Avatar,
} from '@mui/material';
import { Save as SaveIcon } from '@mui/icons-material';

const profileSchema = z.object({
  fullName: z.string().min(3, 'Full Name must be at least 3 characters'),
  email: z.string().email('Please enter a valid email address'),
  phone: z.string().optional().nullable(),
  gender: z.string().optional().nullable(),
  dateOfBirth: z.string().optional().nullable(),
  location: z.string().optional().nullable(),
});

type ProfileFormValues = z.infer<typeof profileSchema>;

export const ProfilePage: React.FC = () => {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const { register, handleSubmit, formState: { errors, isDirty } } = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      fullName: user?.fullName || '',
      email: user?.email || '',
      phone: user?.phone || '',
      gender: user?.gender || '',
      dateOfBirth: user?.dateOfBirth || '',
      location: user?.location || '',
    },
  });

  const updateProfileMutation = useMutation({
    mutationFn: async (values: ProfileFormValues) => {
      return apiClient.put(`/users/${user?.id}`, values);
    },
    onSuccess: (res) => {
      setSuccessMsg('Profile updated successfully.');
      setErrorMsg(null);
      localStorage.setItem('user', JSON.stringify(res.data.data));
      queryClient.invalidateQueries({ queryKey: ['dashboard-stats'] });
      window.location.reload();
    },
    onError: (err: any) => {
      setErrorMsg(err.response?.data?.message || 'Failed to update profile.');
      setSuccessMsg(null);
    },
  });

  const onSubmit = (values: ProfileFormValues) => {
    setSuccessMsg(null);
    setErrorMsg(null);
    updateProfileMutation.mutate(values);
  };

  return (
    <Box>
      <PageHeader
        title="Admin Profile Settings"
        subtitle="Manage your personal profile information and contact details."
      />

      {successMsg && (
        <Alert severity="success" onClose={() => setSuccessMsg(null)} sx={{ mb: 3, borderRadius: 2 }}>
          {successMsg}
        </Alert>
      )}

      {errorMsg && (
        <Alert severity="error" onClose={() => setErrorMsg(null)} sx={{ mb: 3, borderRadius: 2 }}>
          {errorMsg}
        </Alert>
      )}

      <Grid container spacing={4}>
        {/* Profile Card Summary */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Card>
            <CardContent sx={{ p: 4, display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
              <Avatar
                sx={{
                  width: 100,
                  height: 100,
                  bgcolor: 'primary.main',
                  fontSize: '2.5rem',
                  fontWeight: 600,
                  mb: 2.5,
                  boxShadow: (theme) => `0 8px 24px ${theme.palette.primary.main}30`,
                }}
              >
                {user?.fullName?.substring(0, 2).toUpperCase()}
              </Avatar>

              <Typography variant="h5" sx={{ fontWeight: 700, fontFamily: 'Outfit' }}>
                {user?.fullName}
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                {user?.email}
              </Typography>

              <Box sx={{ bgcolor: 'primary.subtle', color: 'primary.main', px: 2, py: 0.5, borderRadius: 1.5, fontWeight: 700, fontSize: '0.85rem' }}>
                {user?.role}
              </Box>

              <Divider sx={{ width: '100%', my: 3 }} />

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1, width: '100%', textAlign: 'left' }}>
                <Box>
                  <Typography variant="caption" color="text.secondary">Account Status</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600, color: 'success.main' }}>
                    Active
                  </Typography>
                </Box>
                <Box>
                  <Typography variant="caption" color="text.secondary">Location Scope</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>
                    {user?.location || 'Central Command'}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Profile Edit Fields */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Card>
            <CardContent sx={{ p: 4 }}>
              <Typography variant="h6" sx={{ mb: 3, fontWeight: 700, fontFamily: 'Outfit' }}>
                Personal Information
              </Typography>
              <form onSubmit={handleSubmit(onSubmit)}>
                <Grid container spacing={3} sx={{ mb: 4 }}>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      {...register('fullName')}
                      label="Full Name"
                      fullWidth
                      required
                      error={!!errors.fullName}
                      helperText={errors.fullName?.message}
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      {...register('email')}
                      label="Email Address"
                      fullWidth
                      required
                      error={!!errors.email}
                      helperText={errors.email?.message}
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      {...register('phone')}
                      label="Phone Number"
                      fullWidth
                      placeholder="e.g. 9841000000"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      {...register('gender')}
                      label="Gender"
                      fullWidth
                      placeholder="e.g. Male, Female"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      {...register('dateOfBirth')}
                      label="Date of Birth"
                      fullWidth
                      placeholder="YYYY-MM-DD"
                    />
                  </Grid>
                  <Grid size={{ xs: 12, sm: 6 }}>
                    <TextField
                      {...register('location')}
                      label="Central Command Location"
                      fullWidth
                    />
                  </Grid>
                </Grid>

                <Button
                  type="submit"
                  variant="contained"
                  color="primary"
                  startIcon={<SaveIcon />}
                  disabled={updateProfileMutation.isPending || !isDirty}
                  sx={{ py: 1.2, px: 3, borderRadius: 2 }}
                >
                  {updateProfileMutation.isPending ? 'Saving...' : 'Save Profile Details'}
                </Button>
              </form>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};
