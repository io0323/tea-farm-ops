import React, { useEffect, useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  Chip,
  CircularProgress,
  IconButton,
  CardActions,
} from '@mui/material';
import { 
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { fetchFields } from '../store/slices/fieldSlice';
import { Field } from '../types';
import FieldForm from '../components/fields/FieldForm';
import DeleteFieldDialog from '../components/fields/DeleteFieldDialog';

const FieldsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { fields, loading } = useAppSelector((state) => state.fields);
  
  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedField, setSelectedField] = useState<Field | null>(null);

  useEffect(() => {
    dispatch(fetchFields());
  }, [dispatch]);

  const handleCreate = () => {
    setSelectedField(null);
    setFormOpen(true);
  };

  const handleEdit = (field: Field) => {
    setSelectedField(field);
    setFormOpen(true);
  };

  const handleDelete = (field: Field) => {
    setSelectedField(field);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedField(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedField(null);
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" sx={{ mb: 3 }}>
        <Typography variant="h4" component="h1">
          フィールド管理
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          size="large"
          onClick={handleCreate}
        >
          新規フィールド
        </Button>
      </Box>

      <Grid container spacing={3}>
        {fields.map((field) => (
          <Grid item xs={12} sm={6} md={4} key={field.id}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  {field.name}
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  {field.location}
                </Typography>
                
                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${field.areaSize}ha`}
                    size="small"
                    color="primary"
                  />
                  {field.soilType && (
                    <Chip
                      label={field.soilType}
                      size="small"
                      variant="outlined"
                    />
                  )}
                </Box>

                {field.notes && (
                  <Typography variant="body2" color="text.secondary">
                    {field.notes}
                  </Typography>
                )}
              </CardContent>
              
              <CardActions sx={{ justifyContent: 'flex-end' }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(field)}
                  color="primary"
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => handleDelete(field)}
                  color="error"
                >
                  <DeleteIcon />
                </IconButton>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {fields.length === 0 && (
        <Box textAlign="center" py={4}>
          <Typography variant="h6" color="text.secondary">
            フィールドが登録されていません
          </Typography>
          <Typography variant="body2" color="text.secondary">
            新規フィールドを追加してください
          </Typography>
        </Box>
      )}

      {/* フォームダイアログ */}
      <FieldForm
        open={formOpen}
        onClose={handleFormClose}
        field={selectedField}
      />

      {/* 削除確認ダイアログ */}
      <DeleteFieldDialog
        open={deleteDialogOpen}
        onClose={handleDeleteDialogClose}
        field={selectedField}
      />
    </Box>
  );
};

export default FieldsPage; 