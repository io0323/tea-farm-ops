import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Grid,
  Alert,
} from '@mui/material';
import { WeatherObservation } from '../../types';
import { useAppSelector, useAppDispatch } from '../../store/hooks';
import { createWeatherObservation, updateWeatherObservation, clearError } from '../../store/slices/weatherObservationSlice';

interface WeatherObservationFormProps {
  open: boolean;
  onClose: () => void;
  observation?: WeatherObservation | null;
}

const WeatherObservationForm: React.FC<WeatherObservationFormProps> = ({ open, onClose, observation }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.weatherObservations);

  const [formData, setFormData] = useState({
    date: '',
    temperature: '',
    rainfall: '',
    humidity: '',
    pestsSeen: '',
    notes: '',
  });

  const isEdit = !!observation;

  useEffect(() => {
    if (observation) {
      setFormData({
        date: observation.date,
        temperature: observation.temperature.toString(),
        rainfall: observation.rainfall.toString(),
        humidity: observation.humidity.toString(),
        pestsSeen: observation.pestsSeen || '',
        notes: observation.notes || '',
      });
    } else {
      setFormData({
        date: '',
        temperature: '',
        rainfall: '',
        humidity: '',
        pestsSeen: '',
        notes: '',
      });
    }
  }, [observation]);

  useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const observationData = {
      date: formData.date,
      temperature: parseFloat(formData.temperature),
      rainfall: parseFloat(formData.rainfall),
      humidity: parseFloat(formData.humidity),
      pestsSeen: formData.pestsSeen || undefined,
      notes: formData.notes || undefined,
    };

    if (isEdit && observation) {
      await dispatch(updateWeatherObservation({ id: observation.id, observation: observationData }));
    } else {
      await dispatch(createWeatherObservation(observationData));
    }

    if (!error) {
      onClose();
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {isEdit ? '天候観測編集' : '新規天候観測作成'}
      </DialogTitle>
      
      <form onSubmit={handleSubmit}>
        <DialogContent>
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="観測日"
                name="date"
                type="date"
                value={formData.date}
                onChange={handleChange}
                required
                margin="normal"
                InputLabelProps={{ shrink: true }}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="気温 (°C)"
                name="temperature"
                type="number"
                value={formData.temperature}
                onChange={handleChange}
                required
                margin="normal"
                inputProps={{ min: -50, max: 50, step: 0.1 }}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="降水量 (mm)"
                name="rainfall"
                type="number"
                value={formData.rainfall}
                onChange={handleChange}
                required
                margin="normal"
                inputProps={{ min: 0, step: 0.1 }}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="湿度 (%)"
                name="humidity"
                type="number"
                value={formData.humidity}
                onChange={handleChange}
                required
                margin="normal"
                inputProps={{ min: 0, max: 100, step: 0.1 }}
              />
            </Grid>

            <Grid item xs={12}>
              <TextField
                fullWidth
                label="害虫の有無"
                name="pestsSeen"
                value={formData.pestsSeen}
                onChange={handleChange}
                margin="normal"
                placeholder="例: アブラムシ、カメムシなど"
              />
            </Grid>

            <Grid item xs={12}>
              <TextField
                fullWidth
                label="備考"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                multiline
                rows={3}
                margin="normal"
              />
            </Grid>
          </Grid>
        </DialogContent>

        <DialogActions>
          <Button onClick={onClose}>
            キャンセル
          </Button>
          <Button
            type="submit"
            variant="contained"
            disabled={loading}
          >
            {loading ? '保存中...' : (isEdit ? '更新' : '作成')}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

export default WeatherObservationForm; 