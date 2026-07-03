import React, { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useParams, useNavigate } from 'react-router-dom';
import { apiClient } from '../../api/client';
import type { Category, Question, QuestionType, Survey, SurveyStatus } from '../../types';
import { PageHeader } from '../../components/PageHeader';
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  MenuItem,
  Button,
  Grid,
  Divider,
  IconButton,
  FormControlLabel,
  Checkbox,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  List,
  ListItem,
  ListItemText,
  CircularProgress,
  Alert,
  Chip,
} from '@mui/material';
import {
  KeyboardArrowLeft as BackIcon,
  Add as AddIcon,
  Delete as DeleteIcon,
  ArrowUpward as UpIcon,
  ArrowDownward as DownIcon,
  Edit as EditIcon,
  Save as SaveIcon,
} from '@mui/icons-material';

const QUESTION_TYPES: QuestionType[] = [
  'Single Choice',
  'Multi Choice',
  'Rating Scale',
  'Ranking',
  'Matrix/Grid',
  'Open End',
  'Choice with Free Writing',
  'Choice with Additional Option',
  'Pickup',
  'Pickup and Rank',
];

export const QuestionBuilderPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const isEditMode = !!id;

  // Survey Meta States
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [categoryId, setCategoryId] = useState('');
  const [status, setStatus] = useState<SurveyStatus>('Draft');
  
  // Questions list state
  const [questions, setQuestions] = useState<Question[]>([]);

  // Dialog Editor state for a single Question
  const [openQuestionDialog, setOpenQuestionDialog] = useState(false);
  const [editingIndex, setEditingIndex] = useState<number | null>(null);
  
  // Question Form fields
  const [qText, setQText] = useState('');
  const [qType, setQType] = useState<QuestionType>('Single Choice');
  const [qRequired, setQRequired] = useState(true);
  const [qOptions, setQOptions] = useState<string[]>([]);
  const [newOption, setNewOption] = useState('');
  
  // Rating specific fields
  const [qMinRating, setQMinRating] = useState(1);
  const [qMaxRating, setQMaxRating] = useState(5);
  const [qMinLabel, setQMinLabel] = useState('Poor');
  const [qMaxLabel, setQMaxLabel] = useState('Excellent');

  // Matrix specific fields
  const [qRows, setQRows] = useState<string[]>([]);
  const [newRow, setNewRow] = useState('');
  const [qCols, setQCols] = useState<string[]>([]);
  const [newCol, setNewCol] = useState('');

  const [validationError, setValidationError] = useState<string | null>(null);

  // Fetch categories
  const { data: categories } = useQuery<Category[]>({
    queryKey: ['categories-builder'],
    queryFn: async () => {
      const res = await apiClient.get('/categories?limit=100');
      return res.data.data || [];
    },
  });

  // Fetch survey details if in edit mode
  const { isLoading: isLoadingSurvey, error: fetchSurveyError } = useQuery<Survey>({
    queryKey: ['survey-edit', id],
    queryFn: async () => {
      const res = await apiClient.get(`/surveys/${id}`);
      return res.data;
    },
    enabled: isEditMode,
  });

  // Populate data when survey loads
  useEffect(() => {
    if (isEditMode && queryClient.getQueryData(['survey-edit', id])) {
      const data = queryClient.getQueryData(['survey-edit', id]) as Survey;
      if (data) {
        setTitle(data.title);
        setDescription(data.description || '');
        setCategoryId(data.categoryId || '');
        setStatus(data.status);
        setQuestions(data.questions || []);
      }
    }
  }, [id, isEditMode, queryClient]);

  // Handle survey load response directly
  const surveyData = queryClient.getQueryData(['survey-edit', id]) as Survey;
  useEffect(() => {
    if (surveyData) {
      setTitle(surveyData.title);
      setDescription(surveyData.description || '');
      setCategoryId(surveyData.categoryId || '');
      setStatus(surveyData.status);
      setQuestions(surveyData.questions || []);
    }
  }, [surveyData]);

  // Mutation to save/update survey
  const saveSurveyMutation = useMutation({
    mutationFn: async () => {
      const payload = {
        title,
        description,
        categoryId: categoryId || null,
        status,
        questions,
      };

      if (isEditMode) {
        return apiClient.put(`/surveys/${id}`, payload);
      } else {
        return apiClient.post('/surveys', payload);
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['surveys'] });
      navigate('/surveys');
    },
    onError: (err: any) => {
      setValidationError(err.response?.data?.message || 'Error occurred while saving survey.');
    },
  });

  // Dialog handlers
  const handleOpenAddQuestion = () => {
    setEditingIndex(null);
    setQText('');
    setQType('Single Choice');
    setQRequired(true);
    setQOptions([]);
    setQRows([]);
    setQCols([]);
    setOpenQuestionDialog(true);
  };

  const handleOpenEditQuestion = (index: number) => {
    const q = questions[index];
    setEditingIndex(index);
    setQText(q.text);
    setQType(q.type);
    setQRequired(q.required);
    
    // Options helper
    if (q.options) {
      setQOptions((q.options as any[]).map(o => typeof o === 'string' ? o : o.label));
    } else {
      setQOptions([]);
    }

    setQMinRating(q.minRating || 1);
    setQMaxRating(q.maxRating || 5);
    setQMinLabel(q.minLabel || 'Poor');
    setQMaxLabel(q.maxLabel || 'Excellent');

    setQRows(q.rows || []);
    setQCols(q.columns || []);

    setOpenQuestionDialog(true);
  };

  const handleAddOption = () => {
    if (newOption.trim()) {
      setQOptions([...qOptions, newOption.trim()]);
      setNewOption('');
    }
  };

  const handleRemoveOption = (index: number) => {
    setQOptions(qOptions.filter((_, i) => i !== index));
  };

  const handleAddRow = () => {
    if (newRow.trim()) {
      setQRows([...qRows, newRow.trim()]);
      setNewRow('');
    }
  };

  const handleRemoveRow = (index: number) => {
    setQRows(qRows.filter((_, i) => i !== index));
  };

  const handleAddCol = () => {
    if (newCol.trim()) {
      setQCols([...qCols, newCol.trim()]);
      setNewCol('');
    }
  };

  const handleRemoveCol = (index: number) => {
    setQCols(qCols.filter((_, i) => i !== index));
  };

  const handleSaveQuestion = () => {
    if (!qText.trim()) return;

    // Validate type configs
    const requiresOptions = [
      'Single Choice',
      'Multi Choice',
      'Ranking',
      'Choice with Free Writing',
      'Choice with Additional Option',
      'Pickup',
      'Pickup and Rank',
    ].includes(qType);

    if (requiresOptions && qOptions.length === 0) {
      alert('Please add at least one option.');
      return;
    }

    if (qType === 'Matrix/Grid' && (qRows.length === 0 || qCols.length === 0)) {
      alert('Grid/Matrix requires at least one row and one column.');
      return;
    }

    const newQuestionObj: Question = {
      id: editingIndex !== null ? questions[editingIndex].id || Math.random().toString() : Math.random().toString(),
      text: qText.trim(),
      type: qType,
      required: qRequired,
      ...(requiresOptions && { options: qOptions }),
      ...(qType === 'Rating Scale' && {
        minRating: qMinRating,
        maxRating: qMaxRating,
        minLabel: qMinLabel,
        maxLabel: qMaxLabel,
      }),
      ...(qType === 'Matrix/Grid' && {
        rows: qRows,
        columns: qCols,
      }),
    };

    if (editingIndex !== null) {
      const list = [...questions];
      list[editingIndex] = newQuestionObj;
      setQuestions(list);
    } else {
      setQuestions([...questions, newQuestionObj]);
    }

    setOpenQuestionDialog(false);
  };

  // Reordering functions
  const moveQuestion = (index: number, direction: 'up' | 'down') => {
    const nextIdx = direction === 'up' ? index - 1 : index + 1;
    if (nextIdx < 0 || nextIdx >= questions.length) return;

    const list = [...questions];
    const temp = list[index];
    list[index] = list[nextIdx];
    list[nextIdx] = temp;
    setQuestions(list);
  };

  const removeQuestion = (index: number) => {
    setQuestions(questions.filter((_, i) => i !== index));
  };

  const handleSaveSurvey = () => {
    setValidationError(null);
    if (!title.trim()) {
      setValidationError('Survey Title is required.');
      return;
    }
    if (questions.length === 0) {
      setValidationError('Please add at least one question to the survey.');
      return;
    }

    saveSurveyMutation.mutate();
  };

  if (isEditMode && isLoadingSurvey) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
        <CircularProgress size={50} />
      </Box>
    );
  }

  if (isEditMode && fetchSurveyError) {
    return (
      <Box sx={{ p: 2 }}>
        <Alert severity="error">Failed to fetch survey. It may have been deleted.</Alert>
      </Box>
    );
  }

  return (
    <Box>
      <Button
        startIcon={<BackIcon />}
        onClick={() => navigate('/surveys')}
        sx={{ mb: 2, color: 'text.secondary', fontWeight: 600 }}
      >
        Cancel & Back
      </Button>

      <PageHeader
        title={isEditMode ? 'Question Builder — Edit Survey' : 'Question Builder — Create Survey'}
        subtitle="Configure the metadata and add custom questions supporting standard JSON survey schemas."
        action={
          <Button
            variant="contained"
            color="primary"
            startIcon={<SaveIcon />}
            onClick={handleSaveSurvey}
            disabled={saveSurveyMutation.isPending}
            sx={{ py: 1.2, px: 3, borderRadius: 2 }}
          >
            {saveSurveyMutation.isPending ? 'Saving...' : 'Save Survey'}
          </Button>
        }
      />

      {validationError && (
        <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>
          {validationError}
        </Alert>
      )}

      <Grid container spacing={4}>
        {/* Survey Config Panel */}
        <Grid size={{ xs: 12, md: 4 }}>
          <Card sx={{ position: 'sticky', top: 100 }}>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" sx={{ mb: 2.5, fontWeight: 700, fontFamily: 'Outfit' }}>
                Survey Configuration
              </Typography>
              <Divider sx={{ mb: 3 }} />

              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
                <TextField
                  label="Survey Title"
                  required
                  fullWidth
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. Rice Cultivation Feedback"
                />

                <TextField
                  label="Description"
                  fullWidth
                  multiline
                  rows={4}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Brief details about the target demographic, goals, etc."
                />

                <TextField
                  select
                  label="Category"
                  fullWidth
                  value={categoryId}
                  onChange={(e) => setCategoryId(e.target.value)}
                >
                  <MenuItem value="">No Category</MenuItem>
                  {categories?.map((cat) => (
                    <MenuItem key={cat.id} value={cat.id}>
                      {cat.name}
                    </MenuItem>
                  ))}
                </TextField>

                <TextField
                  select
                  label="Initial Status"
                  fullWidth
                  value={status}
                  onChange={(e) => setStatus(e.target.value as SurveyStatus)}
                >
                  <MenuItem value="Draft">Draft</MenuItem>
                  <MenuItem value="Active">Active</MenuItem>
                  <MenuItem value="Closed">Closed</MenuItem>
                </TextField>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Survey Questions Panel */}
        <Grid size={{ xs: 12, md: 8 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
            <Typography variant="h5" sx={{ fontWeight: 700, fontFamily: 'Outfit' }}>
              Survey Questionnaire ({questions.length} Questions)
            </Typography>
            <Button
              variant="outlined"
              color="primary"
              startIcon={<AddIcon />}
              onClick={handleOpenAddQuestion}
              sx={{ borderRadius: 2 }}
            >
              Add Question
            </Button>
          </Box>

          {questions.length === 0 ? (
            <Card variant="outlined" sx={{ py: 8, display: 'flex', justifyContent: 'center', borderStyle: 'dashed', borderRadius: 4 }}>
              <Box sx={{ textAlign: 'center', maxWidth: 400 }}>
                <Typography variant="h6" sx={{ fontWeight: 600, mb: 1 }}>
                  Your survey has no questions
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
                  Click "Add Question" to configure choices, matrices, ratings, or ranking structures.
                </Typography>
                <Button
                  variant="contained"
                  startIcon={<AddIcon />}
                  onClick={handleOpenAddQuestion}
                  sx={{ borderRadius: 2 }}
                >
                  Add Question
                </Button>
              </Box>
            </Card>
          ) : (
            questions.map((q, idx) => (
              <Card key={q.id || idx} variant="outlined" sx={{ mb: 2, borderRadius: 3 }}>
                <CardContent sx={{ p: 2.5, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <Box>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 0.5 }}>
                      <Typography variant="body1" sx={{ fontWeight: 600 }}>
                        {idx + 1}. {q.text}
                      </Typography>
                      {q.required && <Chip label="Required" size="small" color="error" variant="outlined" sx={{ height: 20, fontSize: '0.65rem' }} />}
                    </Box>
                    <Typography variant="caption" color="text.secondary">
                      Type: <Box component="span" sx={{ fontWeight: 600, color: 'primary.main' }}>{q.type}</Box>
                      {q.options && ` · Options: ${q.options.length}`}
                      {q.rows && ` · Grid: ${q.rows.length}x${q.columns?.length}`}
                    </Typography>
                  </Box>

                  <Box sx={{ display: 'flex', gap: 0.5 }}>
                    <IconButton size="small" onClick={() => moveQuestion(idx, 'up')} disabled={idx === 0}>
                      <UpIcon fontSize="small" />
                    </IconButton>
                    <IconButton size="small" onClick={() => moveQuestion(idx, 'down')} disabled={idx === questions.length - 1}>
                      <DownIcon fontSize="small" />
                    </IconButton>
                    <IconButton size="small" color="primary" onClick={() => handleOpenEditQuestion(idx)}>
                      <EditIcon fontSize="small" />
                    </IconButton>
                    <IconButton size="small" color="error" onClick={() => removeQuestion(idx)}>
                      <DeleteIcon fontSize="small" />
                    </IconButton>
                  </Box>
                </CardContent>
              </Card>
            ))
          )}
        </Grid>
      </Grid>

      {/* Add / Edit Question Dialog Modal */}
      <Dialog open={openQuestionDialog} onClose={() => setOpenQuestionDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, fontFamily: 'Outfit' }}>
          {editingIndex !== null ? 'Edit Question' : 'Add New Question'}
        </DialogTitle>
        <DialogContent sx={{ pt: 1 }}>
          <TextField
            label="Question Label"
            fullWidth
            required
            margin="normal"
            value={qText}
            onChange={(e) => setQText(e.target.value)}
            placeholder="e.g. Please select your preferred brand of fertilizer."
          />

          <Grid container spacing={2}>
            <Grid size={8}>
              <TextField
                select
                label="Question Type"
                fullWidth
                margin="normal"
                value={qType}
                onChange={(e) => setQType(e.target.value as QuestionType)}
              >
                {QUESTION_TYPES.map((type) => (
                  <MenuItem key={type} value={type}>
                    {type}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid size={4} sx={{ display: 'flex', alignItems: 'center' }}>
              <FormControlLabel
                control={
                  <Checkbox
                    checked={qRequired}
                    onChange={(e) => setQRequired(e.target.checked)}
                  />
                }
                label="Required"
                sx={{ mt: 1 }}
              />
            </Grid>
          </Grid>

          {/* Option-based setup */}
          {[
            'Single Choice',
            'Multi Choice',
            'Ranking',
            'Choice with Free Writing',
            'Choice with Additional Option',
            'Pickup',
            'Pickup and Rank',
          ].includes(qType) && (
            <Box sx={{ mt: 3, p: 2, bgcolor: 'action.hover', borderRadius: 2 }}>
              <Typography variant="subtitle2" sx={{ mb: 1.5, fontWeight: 600 }}>
                Configure Choice Options
              </Typography>
              
              <Box sx={{ display: 'flex', gap: 1, mb: 2 }}>
                <TextField
                  placeholder="Type an option and press Add..."
                  size="small"
                  fullWidth
                  value={newOption}
                  onChange={(e) => setNewOption(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      e.stopPropagation();
                      handleAddOption();
                    }
                  }}
                />
                <Button type="button" variant="contained" size="small" onClick={handleAddOption}>
                  Add
                </Button>
              </Box>

              <List sx={{ p: 0 }}>
                {qOptions.map((opt, oIdx) => (
                  <ListItem
                    key={oIdx}
                    sx={{ px: 1.5, py: 0.5, bgcolor: 'background.paper', mb: 1, borderRadius: 1 }}
                    secondaryAction={
                      <IconButton edge="end" size="small" color="error" onClick={() => handleRemoveOption(oIdx)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    }
                  >
                    <ListItemText primary={<Typography variant="body2">{opt}</Typography>} />
                  </ListItem>
                ))}
              </List>
            </Box>
          )}

          {/* Rating-based setup */}
          {qType === 'Rating Scale' && (
            <Box sx={{ mt: 3, p: 2, bgcolor: 'action.hover', borderRadius: 2 }}>
              <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 600 }}>
                Configure Rating Bounds
              </Typography>
              <Grid container spacing={2}>
                <Grid size={6}>
                  <TextField
                    label="Min Stars"
                    type="number"
                    size="small"
                    value={qMinRating}
                    onChange={(e) => setQMinRating(Number(e.target.value))}
                  />
                </Grid>
                <Grid size={6}>
                  <TextField
                    label="Max Stars"
                    type="number"
                    size="small"
                    value={qMaxRating}
                    onChange={(e) => setQMaxRating(Number(e.target.value))}
                  />
                </Grid>
                <Grid size={6}>
                  <TextField
                    label="Min Label"
                    size="small"
                    value={qMinLabel}
                    onChange={(e) => setQMinLabel(e.target.value)}
                  />
                </Grid>
                <Grid size={6}>
                  <TextField
                    label="Max Label"
                    size="small"
                    value={qMaxLabel}
                    onChange={(e) => setQMaxLabel(e.target.value)}
                  />
                </Grid>
              </Grid>
            </Box>
          )}

          {/* Matrix-based setup */}
          {qType === 'Matrix/Grid' && (
            <Box sx={{ mt: 3, p: 2, bgcolor: 'action.hover', borderRadius: 2 }}>
              <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 600 }}>
                Configure Matrix Row & Columns
              </Typography>

              {/* Rows */}
              <Typography variant="caption" sx={{ fontWeight: 600, display: 'block', mb: 1 }}>Rows (Questions/Statements)</Typography>
              <Box sx={{ display: 'flex', gap: 1, mb: 1.5 }}>
                <TextField
                  placeholder="Add a row statement..."
                  size="small"
                  fullWidth
                  value={newRow}
                  onChange={(e) => setNewRow(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      e.stopPropagation();
                      handleAddRow();
                    }
                  }}
                />
                <Button type="button" variant="outlined" size="small" onClick={handleAddRow}>Add</Button>
              </Box>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 3 }}>
                {qRows.map((row, rIdx) => (
                  <Chip
                    key={rIdx}
                    label={row}
                    size="small"
                    onDelete={() => handleRemoveRow(rIdx)}
                    sx={{ borderRadius: 1.5 }}
                  />
                ))}
              </Box>

              {/* Columns */}
              <Typography variant="caption" sx={{ fontWeight: 600, display: 'block', mb: 1 }}>Columns (Scale Options)</Typography>
              <Box sx={{ display: 'flex', gap: 1, mb: 1.5 }}>
                <TextField
                  placeholder="Add a column label..."
                  size="small"
                  fullWidth
                  value={newCol}
                  onChange={(e) => setNewCol(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault();
                      e.stopPropagation();
                      handleAddCol();
                    }
                  }}
                />
                <Button type="button" variant="outlined" size="small" onClick={handleAddCol}>Add</Button>
              </Box>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                {qCols.map((col, cIdx) => (
                  <Chip
                    key={cIdx}
                    label={col}
                    size="small"
                    onDelete={() => handleRemoveCol(cIdx)}
                    sx={{ borderRadius: 1.5 }}
                  />
                ))}
              </Box>
            </Box>
          )}
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 3 }}>
          <Button onClick={() => setOpenQuestionDialog(false)} color="inherit">
            Cancel
          </Button>
          <Button variant="contained" onClick={handleSaveQuestion}>
            {editingIndex !== null ? 'Save Changes' : 'Add Question'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};
