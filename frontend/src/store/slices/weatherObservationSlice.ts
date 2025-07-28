import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { WeatherObservation } from '../../types';
import { apiClient } from '../../services/apiClient';

// 非同期アクション
export const fetchWeatherObservations = createAsyncThunk(
  'weatherObservations/fetchWeatherObservations',
  async () => {
    const response = await apiClient.get('/api/weather-observations');
    return response.data;
  }
);

export const fetchWeatherObservationById = createAsyncThunk(
  'weatherObservations/fetchWeatherObservationById',
  async (id: number) => {
    const response = await apiClient.get(`/api/weather-observations/${id}`);
    return response.data;
  }
);

export const createWeatherObservation = createAsyncThunk(
  'weatherObservations/createWeatherObservation',
  async (observation: Omit<WeatherObservation, 'id'>) => {
    const response = await apiClient.post('/api/weather-observations', observation);
    return response.data;
  }
);

export const updateWeatherObservation = createAsyncThunk(
  'weatherObservations/updateWeatherObservation',
  async ({ id, observation }: { id: number; observation: Partial<WeatherObservation> }) => {
    const response = await apiClient.put(`/api/weather-observations/${id}`, observation);
    return response.data;
  }
);

export const deleteWeatherObservation = createAsyncThunk(
  'weatherObservations/deleteWeatherObservation',
  async (id: number) => {
    await apiClient.delete(`/api/weather-observations/${id}`);
    return id;
  }
);

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
      // fetchWeatherObservations
      .addCase(fetchWeatherObservations.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchWeatherObservations.fulfilled, (state, action) => {
        state.loading = false;
        state.weatherObservations = action.payload;
      })
      .addCase(fetchWeatherObservations.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '天候観測の取得に失敗しました';
      })
      // fetchWeatherObservationById
      .addCase(fetchWeatherObservationById.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchWeatherObservationById.fulfilled, (state, action) => {
        state.loading = false;
        state.currentWeatherObservation = action.payload;
      })
      .addCase(fetchWeatherObservationById.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '天候観測の取得に失敗しました';
      })
      // createWeatherObservation
      .addCase(createWeatherObservation.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createWeatherObservation.fulfilled, (state, action) => {
        state.loading = false;
        state.weatherObservations.push(action.payload);
      })
      .addCase(createWeatherObservation.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '天候観測の作成に失敗しました';
      })
      // updateWeatherObservation
      .addCase(updateWeatherObservation.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateWeatherObservation.fulfilled, (state, action) => {
        state.loading = false;
        const index = state.weatherObservations.findIndex(obs => obs.id === action.payload.id);
        if (index !== -1) {
          state.weatherObservations[index] = action.payload;
        }
        if (state.currentWeatherObservation?.id === action.payload.id) {
          state.currentWeatherObservation = action.payload;
        }
      })
      .addCase(updateWeatherObservation.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '天候観測の更新に失敗しました';
      })
      // deleteWeatherObservation
      .addCase(deleteWeatherObservation.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(deleteWeatherObservation.fulfilled, (state, action) => {
        state.loading = false;
        state.weatherObservations = state.weatherObservations.filter(obs => obs.id !== action.payload);
        if (state.currentWeatherObservation?.id === action.payload) {
          state.currentWeatherObservation = null;
        }
      })
      .addCase(deleteWeatherObservation.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '天候観測の削除に失敗しました';
      });
  },
});

export const { clearError, clearCurrentWeatherObservation } = weatherObservationSlice.actions;
export default weatherObservationSlice.reducer; 