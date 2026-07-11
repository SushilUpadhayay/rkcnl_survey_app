import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, useNavigate } from 'react-router-dom';
import { apiClient } from '../../api/client';
import type { Survey, Question } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Chip,
  Grid,
  Button,
  CircularProgress,
  Alert,
  Divider,
  Paper,
  RadioGroup,
  FormControlLabel,
  Radio,
  Checkbox,
  FormGroup,
  Rating,
  TextField,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from '@mui/material';
import { Edit as EditIcon, KeyboardArrowLeft as BackIcon } from '@mui/icons-material';

export const SurveyDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  const { data: survey, isLoading, error } = useQuery<Survey>({
    queryKey: ['survey', id],
    queryFn: async () => {
      const response = await apiClient.get(`/surveys/${id}`);
      return response.data;
    },
  });

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
        <CircularProgress size={50} />
      </Box>
    );
  }

  if (error || !survey) {
    return (
      <Box sx={{ p: 2 }}>
        <Alert severity="error">Failed to load survey details. It may have been deleted or does not exist.</Alert>
      </Box>
    );
  }

  const renderQuestionPreview = (q: Question, idx: number) => {
    return (
      <Card key={q.id || idx} variant="outlined" sx={{ mb: 3, borderRadius: 3, borderColor: 'divider' }}>
        <CardContent sx={{ p: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', mb: 2 }}>
            <Typography variant="subtitle1" sx={{ fontWeight: 700, display: 'flex', gap: 1 }}>
              <Box component="span" color="primary.main">Q{idx + 1}.</Box>
              {q.text}
              {q.required && <Box component="span" sx={{ color: 'error.main', ml: 0.5 }}>*</Box>}
            </Typography>
            <Chip
              label={q.type}
              size="small"
              color="secondary"
              variant="outlined"
              sx={{ fontWeight: 600, fontSize: '0.75rem' }}
            />
          </Box>

          <Box sx={{ pl: 4, mt: 1.5 }}>
            {/* 1. Single Choice */}
            {q.type === 'Single Choice' && q.options && (
              <RadioGroup>
                {(q.options as any[]).map((opt, oIdx) => {
                  const label = typeof opt === 'string' ? opt : opt.label;
                  return <FormControlLabel key={oIdx} value={label} control={<Radio disabled />} label={label} />;
                })}
              </RadioGroup>
            )}

            {/* 2. Multi Choice */}
            {q.type === 'Multi Choice' && q.options && (
              <FormGroup>
                {(q.options as any[]).map((opt, oIdx) => {
                  const label = typeof opt === 'string' ? opt : opt.label;
                  return <FormControlLabel key={oIdx} control={<Checkbox disabled />} label={label} />;
                })}
              </FormGroup>
            )}

            {/* 3. Rating Scale */}
            {q.type === 'Rating Scale' && (
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, py: 1 }}>
                {q.minLabel && <Typography variant="body2" color="text.secondary">{q.minLabel}</Typography>}
                <Rating max={q.maxRating || 5} disabled value={0} />
                {q.maxLabel && <Typography variant="body2" color="text.secondary">{q.maxLabel}</Typography>}
              </Box>
            )}

            {/* 4. Ranking */}
            {q.type === 'Ranking' && q.options && (
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 0.5 }}>
                  (Enumerator will rank the options below)
                </Typography>
                {(q.options as any[]).map((opt, oIdx) => {
                  const label = typeof opt === 'string' ? opt : opt.label;
                  return (
                    <Box key={oIdx} sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                      <Box sx={{ width: 24, height: 24, borderRadius: '50%', border: '1px solid', borderColor: 'divider', display: 'flex', alignItems: 'center', justify: 'center', fontSize: '0.75rem', fontWeight: 600 }}>
                        {oIdx + 1}
                      </Box>
                      <Typography variant="body2">{label}</Typography>
                    </Box>
                  );
                })}
              </Box>
            )}

            {/* 5. Matrix/Grid */}
            {q.type === 'Matrix/Grid' && q.rows && q.columns && (
              <TableContainer component={Paper} variant="outlined" sx={{ mt: 1, overflowX: 'auto', borderRadius: 2 }}>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell sx={{ fontWeight: 600 }}>Row \ Col</TableCell>
                      {q.columns.map((col, cIdx) => (
                        <TableCell key={cIdx} align="center" sx={{ fontWeight: 600 }}>{col}</TableCell>
                      ))}
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {q.rows.map((row, rIdx) => (
                      <TableRow key={rIdx}>
                        <TableCell sx={{ fontWeight: 500 }}>{row}</TableCell>
                        {q.columns!.map((_, cIdx) => (
                          <TableCell key={cIdx} align="center">
                            <Radio disabled />
                          </TableCell>
                        ))}
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            )}

            {/* 6. Open End */}
            {q.type === 'Open End' && (
              <TextField
                disabled
                fullWidth
                multiline
                rows={2}
                placeholder="Respondent free text entry..."
                size="small"
              />
            )}

            {/* 7. Choice with Free Writing / Additional Option */}
            {(q.type === 'Choice with Free Writing' || q.type === 'Choice with Additional Option') && q.options && (
              <RadioGroup>
                {(q.options as any[]).map((opt, oIdx) => {
                  const label = typeof opt === 'string' ? opt : opt.label;
                  return <FormControlLabel key={oIdx} value={label} control={<Radio disabled />} label={label} />;
                })}
                <FormControlLabel
                  value="other"
                  control={<Radio disabled />}
                  label={
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Typography variant="body2">Other (specify):</Typography>
                      <TextField disabled size="small" sx={{ width: 150 }} placeholder="..." />
                    </Box>
                  }
                />
              </RadioGroup>
            )}

            {/* 8. Pickup / Pickup and Rank */}
            {(q.type === 'Pickup' || q.type === 'Pickup and Rank') && q.options && (
              <Box>
                <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mb: 1 }}>
                  (Select items to pick {q.type === 'Pickup and Rank' ? 'and order by rank' : ''})
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {(q.options as any[]).map((opt, oIdx) => {
                    const label = typeof opt === 'string' ? opt : opt.label;
                    return (
                      <Chip
                        key={oIdx}
                        label={label}
                        variant="outlined"
                        onClick={() => {}}
                        sx={{ borderRadius: 1.5 }}
                      />
                    );
                  })}
                </Box>
              </Box>
            )}
          </Box>
        </CardContent>
      </Card>
    );
  };

  return (
    <Box>
      <Button
        startIcon={<BackIcon />}
        onClick={() => navigate('/surveys')}
        sx={{ mb: 2, color: 'text.secondary', fontWeight: 600 }}
      >
        Back to Surveys
      </Button>

      <PageHeader
        title={survey.title}
        subtitle={survey.category?.name ? `Category: ${survey.category.name}` : 'No Category'}
        action={
          <Button
            variant="contained"
            color="primary"
            startIcon={<EditIcon />}
            onClick={() => navigate(`/surveys/${survey.id}/edit`)}
            sx={{ borderRadius: 2 }}
          >
            Edit Questions
          </Button>
        }
      />

      <Grid container spacing={4} sx={{ mb: 4 }}>
        {/* Detail overview cards */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ fontWeight: 700, mb: 2, fontFamily: 'Outfit' }}>
                Survey Overview
              </Typography>
              <Divider sx={{ mb: 2 }} />

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">Status:</Typography>
                  <Chip
                    label={survey.status}
                    color={survey.status === 'Active' ? 'success' : survey.status === 'Draft' ? 'default' : 'error'}
                    size="small"
                    sx={{ fontWeight: 600 }}
                  />
                </Box>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">Total Questions:</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>{survey.questions?.length || 0}</Typography>
                </Box>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">Responses Sync:</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>{survey._count?.responses || 0}</Typography>
                </Box>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">Assigned Users:</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>{survey._count?.assignments || 0}</Typography>
                </Box>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">Created By:</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>{survey.createdBy?.fullName || 'Admin'}</Typography>
                </Box>
                <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                  <Typography variant="body2" color="text.secondary">Last Updated:</Typography>
                  <Typography variant="body2" sx={{ fontWeight: 600 }}>{new Date(survey.updatedAt).toLocaleDateString()}</Typography>
                </Box>
              </Box>

              {survey.description && (
                <Box sx={{ mt: 3 }}>
                  <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 600, mb: 0.5 }}>
                    Description:
                  </Typography>
                  <Typography variant="body2" sx={{ bgcolor: 'action.hover', p: 1.5, borderRadius: 2 }}>
                    {survey.description}
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>

        {/* Live Preview List */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Typography variant="h5" sx={{ fontWeight: 700, mb: 2, fontFamily: 'Outfit' }}>
            Questionnaire Live Preview
          </Typography>
          
          {(!survey.questions || survey.questions.length === 0) ? (
            <Alert severity="warning" sx={{ borderRadius: 2 }}>
              This survey contains no questions. Click "Edit Questions" to use the Question Builder.
            </Alert>
          ) : (
            survey.questions.map((q, idx) => renderQuestionPreview(q, idx))
          )}
        </Grid>
      </Grid>
    </Box>
  );
};
