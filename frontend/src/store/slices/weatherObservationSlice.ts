import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { WeatherObservation, WeatherObservationSearchParams } from '../../types';
import apiClient from '../../services/api';

interface WeatherObservationState {
  weatherObservations: WeatherObservation[];
  currentWeatherObservation: WeatherObservation | null;
  loading: boolean;
  error: string | null;
}

const initialState: WeatherObservationState = {
  weatherObservations: [],
  currentWeatherObservation: null,
  loading: false,
  error: null,
};

export const fetchWeatherObservations = createAsyncThunk(
  'weatherObservations/fetchWeatherObservations',
  async (params?: WeatherObservationSearchParams, { rejectWithValue }) => {
    try {
      const observations = await apiClient.getWeatherObservations(params);
      return observations;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || '天候観測の取得に失敗しました');
    }
  }
);

const weatherObservationSlice = createSlice({
  name: 'weatherObservations',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    clearCurrentWeatherObservation: (state) => {
      state.currentWeatherObservation = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchWeatherObservations.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchWeatherObservations.fulfilled, (state, action: PayloadAction<WeatherObservation[]>) => {
        state.loading = false;
        state.weatherObservations = action.payload;
        state.error = null;
      })
      .addCase(fetchWeatherObservations.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { clearError, clearCurrentWeatherObservation } = weatherObservationSlice.actions;
export default weatherObservationSlice.reducer; 