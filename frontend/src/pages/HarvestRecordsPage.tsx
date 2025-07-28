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
import { fetchHarvestRecords } from '../store/slices/harvestRecordSlice';
import { HarvestRecord } from '../types';
import HarvestRecordForm from '../components/harvest-records/HarvestRecordForm';
import DeleteHarvestRecordDialog from '../components/harvest-records/DeleteHarvestRecordDialog';

const HarvestRecordsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { harvestRecords, loading } = useAppSelector((state) => state.harvestRecords);
  
  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedRecord, setSelectedRecord] = useState<HarvestRecord | null>(null);

  useEffect(() => {
    dispatch(fetchHarvestRecords());
  }, [dispatch]);

  const handleCreate = () => {
    setSelectedRecord(null);
    setFormOpen(true);
  };

  const handleEdit = (record: HarvestRecord) => {
    setSelectedRecord(record);
    setFormOpen(true);
  };

  const handleDelete = (record: HarvestRecord) => {
    setSelectedRecord(record);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedRecord(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedRecord(null);
  };

  const getGradeColor = (grade: string) => {
    switch (grade) {
      case 'PREMIUM':
        return 'success';
      case 'HIGH':
        return 'primary';
      case 'MEDIUM':
        return 'warning';
      case 'LOW':
        return 'error';
      default:
        return 'default';
    }
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
          収穫記録
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          size="large"
          onClick={handleCreate}
        >
          新規記録
        </Button>
      </Box>

      <Grid container spacing={3}>
        {harvestRecords.map((record) => (
          <Grid item xs={12} sm={6} md={4} key={record.id}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  {record.teaGrade}
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  収穫日: {record.harvestDate}
                </Typography>
                
                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${record.quantityKg}kg`}
                    size="small"
                    color="primary"
                  />
                  <Chip
                    label={record.teaGrade}
                    size="small"
                    color={getGradeColor(record.teaGrade) as any}
                  />
                </Box>

                {record.notes && (
                  <Typography variant="body2" color="text.secondary">
                    {record.notes}
                  </Typography>
                )}
              </CardContent>
              
              <CardActions sx={{ justifyContent: 'flex-end' }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(record)}
                  color="primary"
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => handleDelete(record)}
                  color="error"
                >
                  <DeleteIcon />
                </IconButton>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {harvestRecords.length === 0 && (
        <Box textAlign="center" py={4}>
          <Typography variant="h6" color="text.secondary">
            収穫記録が登録されていません
          </Typography>
          <Typography variant="body2" color="text.secondary">
            新規記録を追加してください
          </Typography>
        </Box>
      )}

      {/* フォームダイアログ */}
      <HarvestRecordForm
        open={formOpen}
        onClose={handleFormClose}
        record={selectedRecord}
      />

      {/* 削除確認ダイアログ */}
      <DeleteHarvestRecordDialog
        open={deleteDialogOpen}
        onClose={handleDeleteDialogClose}
        record={selectedRecord}
      />
    </Box>
  );
};

export default HarvestRecordsPage; 