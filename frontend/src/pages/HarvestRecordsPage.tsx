import React, { useEffect } from 'react';
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  Chip,
  CircularProgress,
} from '@mui/material';
import { Add as AddIcon } from '@mui/icons-material';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { fetchHarvestRecords } from '../store/slices/harvestRecordSlice';
import { TeaGrade } from '../types';

const HarvestRecordsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { harvestRecords, loading } = useAppSelector((state) => state.harvestRecords);

  useEffect(() => {
    dispatch(fetchHarvestRecords());
  }, [dispatch]);

  const getGradeColor = (grade: TeaGrade) => {
    switch (grade) {
      case TeaGrade.PREMIUM:
        return 'error';
      case TeaGrade.HIGH:
        return 'warning';
      case TeaGrade.MEDIUM:
        return 'info';
      case TeaGrade.STANDARD:
        return 'default';
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
                  {record.field.name}
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
            新規収穫記録を追加してください
          </Typography>
        </Box>
      )}
    </Box>
  );
};

export default HarvestRecordsPage; 