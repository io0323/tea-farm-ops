import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { HarvestRecord, HarvestRecordSearchParams } from '../../types';
import apiClient from '../../services/api';

interface HarvestRecordState {
  harvestRecords: HarvestRecord[];
  currentHarvestRecord: HarvestRecord | null;
  loading: boolean;
  error: string | null;
}

const initialState: HarvestRecordState = {
  harvestRecords: [],
  currentHarvestRecord: null,
  loading: false,
  error: null,
};

export const fetchHarvestRecords = createAsyncThunk(
  'harvestRecords/fetchHarvestRecords',
  async (params?: HarvestRecordSearchParams, { rejectWithValue }) => {
    try {
      const records = await apiClient.getHarvestRecords(params);
      return records;
    } catch (error: any) {
      return rejectWithValue(error.response?.data?.message || '収穫記録の取得に失敗しました');
    }
  }
);

const harvestRecordSlice = createSlice({
  name: 'harvestRecords',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    clearCurrentHarvestRecord: (state) => {
      state.currentHarvestRecord = null;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchHarvestRecords.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchHarvestRecords.fulfilled, (state, action: PayloadAction<HarvestRecord[]>) => {
        state.loading = false;
        state.harvestRecords = action.payload;
        state.error = null;
      })
      .addCase(fetchHarvestRecords.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { clearError, clearCurrentHarvestRecord } = harvestRecordSlice.actions;
export default harvestRecordSlice.reducer; 