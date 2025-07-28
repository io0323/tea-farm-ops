import React, { useEffect } from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  CircularProgress,
} from '@mui/material';
import {
  Agriculture as FieldIcon,
  Assignment as TaskIcon,
  LocalShipping as HarvestIcon,
  WbSunny as WeatherIcon,
} from '@mui/icons-material';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { fetchFields } from '../store/slices/fieldSlice';
import { fetchTasks } from '../store/slices/taskSlice';
import { fetchHarvestRecords } from '../store/slices/harvestRecordSlice';
import { fetchWeatherObservations } from '../store/slices/weatherObservationSlice';

const DashboardPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { fields, loading: fieldsLoading } = useAppSelector((state) => state.fields);
  const { tasks, loading: tasksLoading } = useAppSelector((state) => state.tasks);
  const { harvestRecords, loading: harvestLoading } = useAppSelector((state) => state.harvestRecords);
  const { weatherObservations, loading: weatherLoading } = useAppSelector((state) => state.weatherObservations);

  useEffect(() => {
    // データを取得
    dispatch(fetchFields());
    dispatch(fetchTasks());
    dispatch(fetchHarvestRecords());
    dispatch(fetchWeatherObservations());
  }, [dispatch]);

  const isLoading = fieldsLoading || tasksLoading || harvestLoading || weatherLoading;

  const stats = [
    {
      title: 'フィールド数',
      value: fields.length,
      icon: <FieldIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      color: '#2e7d32',
    },
    {
      title: 'タスク数',
      value: tasks.length,
      icon: <TaskIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      color: '#1976d2',
    },
    {
      title: '収穫記録',
      value: harvestRecords.length,
      icon: <HarvestIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      color: '#ed6c02',
    },
    {
      title: '天候観測',
      value: weatherObservations.length,
      icon: <WeatherIcon sx={{ fontSize: 40, color: 'primary.main' }} />,
      color: '#9c27b0',
    },
  ];

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" component="h1" gutterBottom>
        ダッシュボード
      </Typography>
      
      <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
        茶園運営の概要を確認できます
      </Typography>

      <Grid container spacing={3}>
        {stats.map((stat) => (
          <Grid item xs={12} sm={6} md={3} key={stat.title}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Box display="flex" alignItems="center" justifyContent="space-between">
                  <Box>
                    <Typography variant="h3" component="div" sx={{ fontWeight: 'bold', color: stat.color }}>
                      {stat.value}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      {stat.title}
                    </Typography>
                  </Box>
                  {stat.icon}
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                最近のフィールド
              </Typography>
              {fields.slice(0, 5).map((field) => (
                <Box key={field.id} sx={{ py: 1, borderBottom: '1px solid #eee' }}>
                  <Typography variant="body1">{field.name}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    {field.location} - {field.areaSize}ha
                  </Typography>
                </Box>
              ))}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                最近のタスク
              </Typography>
              {tasks.slice(0, 5).map((task) => (
                <Box key={task.id} sx={{ py: 1, borderBottom: '1px solid #eee' }}>
                  <Typography variant="body1">{task.taskType}</Typography>
                  <Typography variant="body2" color="text.secondary">
                    {task.field.name} - {task.status}
                  </Typography>
                </Box>
              ))}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default DashboardPage; 