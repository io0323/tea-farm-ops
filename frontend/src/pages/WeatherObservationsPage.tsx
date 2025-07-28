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
import { fetchWeatherObservations } from '../store/slices/weatherObservationSlice';
import { WeatherObservation } from '../types';
import WeatherObservationForm from '../components/weather-observations/WeatherObservationForm';
import DeleteWeatherObservationDialog from '../components/weather-observations/DeleteWeatherObservationDialog';

const WeatherObservationsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { weatherObservations, loading } = useAppSelector((state) => state.weatherObservations);
  
  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedObservation, setSelectedObservation] = useState<WeatherObservation | null>(null);

  useEffect(() => {
    dispatch(fetchWeatherObservations());
  }, [dispatch]);

  const handleCreate = () => {
    setSelectedObservation(null);
    setFormOpen(true);
  };

  const handleEdit = (observation: WeatherObservation) => {
    setSelectedObservation(observation);
    setFormOpen(true);
  };

  const handleDelete = (observation: WeatherObservation) => {
    setSelectedObservation(observation);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedObservation(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedObservation(null);
  };

  const getTemperatureColor = (temp: number) => {
    if (temp >= 30) return 'error';
    if (temp >= 25) return 'warning';
    if (temp >= 15) return 'success';
    return 'info';
  };

  const getRainfallColor = (rainfall: number) => {
    if (rainfall >= 50) return 'error';
    if (rainfall >= 20) return 'warning';
    return 'info';
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
          天候観測
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          size="large"
          onClick={handleCreate}
        >
          新規観測
        </Button>
      </Box>

      <Grid container spacing={3}>
        {weatherObservations.map((observation) => (
          <Grid item xs={12} sm={6} md={4} key={observation.id}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  {observation.date}
                </Typography>
                
                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${observation.temperature}°C`}
                    size="small"
                    color={getTemperatureColor(observation.temperature) as any}
                  />
                  <Chip
                    label={`${observation.rainfall}mm`}
                    size="small"
                    color={getRainfallColor(observation.rainfall) as any}
                  />
                  <Chip
                    label={`${observation.humidity}%`}
                    size="small"
                    variant="outlined"
                  />
                </Box>

                {observation.pestsSeen && (
                  <Typography variant="body2" color="error" sx={{ mb: 1 }}>
                    害虫: {observation.pestsSeen}
                  </Typography>
                )}

                {observation.notes && (
                  <Typography variant="body2" color="text.secondary">
                    {observation.notes}
                  </Typography>
                )}
              </CardContent>
              
              <CardActions sx={{ justifyContent: 'flex-end' }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(observation)}
                  color="primary"
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => handleDelete(observation)}
                  color="error"
                >
                  <DeleteIcon />
                </IconButton>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {weatherObservations.length === 0 && (
        <Box textAlign="center" py={4}>
          <Typography variant="h6" color="text.secondary">
            天候観測が登録されていません
          </Typography>
          <Typography variant="body2" color="text.secondary">
            新規観測を追加してください
          </Typography>
        </Box>
      )}

      {/* フォームダイアログ */}
      <WeatherObservationForm
        open={formOpen}
        onClose={handleFormClose}
        observation={selectedObservation}
      />

      {/* 削除確認ダイアログ */}
      <DeleteWeatherObservationDialog
        open={deleteDialogOpen}
        onClose={handleDeleteDialogClose}
        observation={selectedObservation}
      />
    </Box>
  );
};

export default WeatherObservationsPage; 