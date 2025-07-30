import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { HarvestRecord } from '../../types';
import { apiClient } from '../../services/api';

// 非同期アクション
export const fetchHarvestRecords = createAsyncThunk(
  'harvestRecords/fetchHarvestRecords',
  async () => {
    const response = await apiClient.getHarvestRecords();
    return response;
  }
);

export const fetchHarvestRecordById = createAsyncThunk(
  'harvestRecords/fetchHarvestRecordById',
  async (id: number) => {
    const response = await apiClient.getHarvestRecord(id);
    return response;
  }
);

export const createHarvestRecord = createAsyncThunk(
  'harvestRecords/createHarvestRecord',
  async (record: Omit<HarvestRecord, 'id'>) => {
    const response = await apiClient.createHarvestRecord(record);
    return response;
  }
);

export const updateHarvestRecord = createAsyncThunk(
  'harvestRecords/updateHarvestRecord',
  async ({ id, record }: { id: number; record: Partial<HarvestRecord> }) => {
    const response = await apiClient.updateHarvestRecord(id, record);
    return response;
  }
);

export const deleteHarvestRecord = createAsyncThunk(
  'harvestRecords/deleteHarvestRecord',
  async (id: number) => {
    await apiClient.deleteHarvestRecord(id);
    return id;
  }
);

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
      // fetchHarvestRecords
      .addCase(fetchHarvestRecords.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchHarvestRecords.fulfilled, (state, action) => {
        state.loading = false;
        state.harvestRecords = action.payload;
      })
      .addCase(fetchHarvestRecords.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '収穫記録の取得に失敗しました';
      })
      // fetchHarvestRecordById
      .addCase(fetchHarvestRecordById.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchHarvestRecordById.fulfilled, (state, action) => {
        state.loading = false;
        state.currentHarvestRecord = action.payload;
      })
      .addCase(fetchHarvestRecordById.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '収穫記録の取得に失敗しました';
      })
      // createHarvestRecord
      .addCase(createHarvestRecord.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createHarvestRecord.fulfilled, (state, action) => {
        state.loading = false;
        state.harvestRecords.push(action.payload);
      })
      .addCase(createHarvestRecord.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '収穫記録の作成に失敗しました';
      })
      // updateHarvestRecord
      .addCase(updateHarvestRecord.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateHarvestRecord.fulfilled, (state, action) => {
        state.loading = false;
        const index = state.harvestRecords.findIndex(record => record.id === action.payload.id);
        if (index !== -1) {
          state.harvestRecords[index] = action.payload;
        }
        if (state.currentHarvestRecord?.id === action.payload.id) {
          state.currentHarvestRecord = action.payload;
        }
      })
      .addCase(updateHarvestRecord.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '収穫記録の更新に失敗しました';
      })
      // deleteHarvestRecord
      .addCase(deleteHarvestRecord.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(deleteHarvestRecord.fulfilled, (state, action) => {
        state.loading = false;
        state.harvestRecords = state.harvestRecords.filter(record => record.id !== action.payload);
        if (state.currentHarvestRecord?.id === action.payload) {
          state.currentHarvestRecord = null;
        }
      })
      .addCase(deleteHarvestRecord.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message || '収穫記録の削除に失敗しました';
      });
  },
});

export const { clearError, clearCurrentHarvestRecord } = harvestRecordSlice.actions;
export default harvestRecordSlice.reducer; 