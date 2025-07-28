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
import { fetchWeatherObservations } from '../store/slices/weatherObservationSlice';

const WeatherObservationsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { weatherObservations, loading } = useAppSelector((state) => state.weatherObservations);

  useEffect(() => {
    dispatch(fetchWeatherObservations());
  }, [dispatch]);

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
                  {observation.field.name}
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  観測日: {observation.date}
                </Typography>
                
                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${observation.temperature}°C`}
                    size="small"
                    color="primary"
                  />
                  <Chip
                    label={`${observation.rainfall}mm`}
                    size="small"
                    color="info"
                  />
                  <Chip
                    label={`${observation.humidity}%`}
                    size="small"
                    color="secondary"
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
            新規天候観測を追加してください
          </Typography>
        </Box>
      )}
    </Box>
  );
};

export default WeatherObservationsPage; 