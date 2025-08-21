import { createSlice, createAsyncThunk, PayloadAction } from "@reduxjs/toolkit";
import { Field, FieldSearchParams } from "../../types";
import apiClient from "../../services/api";

// フィールド状態の型定義
interface FieldState {
  fields: Field[];
  currentField: Field | null;
  loading: boolean;
  error: string | null;
}

// 初期状態
const initialState: FieldState = {
  fields: [],
  currentField: null,
  loading: false,
  error: null,
};

// 非同期アクション
export const fetchFields = createAsyncThunk(
  "fields/fetchFields",
  async (params?: FieldSearchParams, { rejectWithValue } = {} as any) => {
    try {
      const fields = await apiClient.getFields(params);
      return fields;
    } catch (error: any) {
      return rejectWithValue(
        error.response?.data?.message || "フィールドの取得に失敗しました",
      );
    }
  },
);

export const fetchFieldById = createAsyncThunk(
  "fields/fetchFieldById",
  async (id: number, { rejectWithValue }) => {
    try {
      const field = await apiClient.getField(id);
      return field;
    } catch (error: any) {
      return rejectWithValue(
        error.response?.data?.message || "フィールドの取得に失敗しました",
      );
    }
  },
);

export const createField = createAsyncThunk(
  "fields/createField",
  async (field: Omit<Field, "id">, { rejectWithValue }) => {
    try {
      const newField = await apiClient.createField(field);
      return newField;
    } catch (error: any) {
      return rejectWithValue(
        error.response?.data?.message || "フィールドの作成に失敗しました",
      );
    }
  },
);

export const updateField = createAsyncThunk(
  "fields/updateField",
  async (
    { id, field }: { id: number; field: Partial<Field> },
    { rejectWithValue },
  ) => {
    try {
      const updatedField = await apiClient.updateField(id, field);
      return updatedField;
    } catch (error: any) {
      return rejectWithValue(
        error.response?.data?.message || "フィールドの更新に失敗しました",
      );
    }
  },
);

export const deleteField = createAsyncThunk(
  "fields/deleteField",
  async (id: number, { rejectWithValue }) => {
    try {
      await apiClient.deleteField(id);
      return id;
    } catch (error: any) {
      return rejectWithValue(
        error.response?.data?.message || "フィールドの削除に失敗しました",
      );
    }
  },
);

// スライス
const fieldSlice = createSlice({
  name: "fields",
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    clearCurrentField: (state) => {
      state.currentField = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // フィールド一覧取得
      .addCase(fetchFields.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(
        fetchFields.fulfilled,
        (state, action: PayloadAction<Field[]>) => {
          state.loading = false;
          state.fields = action.payload;
          state.error = null;
        },
      )
      .addCase(fetchFields.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // フィールド詳細取得
      .addCase(fetchFieldById.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(
        fetchFieldById.fulfilled,
        (state, action: PayloadAction<Field>) => {
          state.loading = false;
          state.currentField = action.payload;
          state.error = null;
        },
      )
      .addCase(fetchFieldById.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // フィールド作成
      .addCase(createField.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createField.fulfilled, (state, action: PayloadAction<Field>) => {
        state.loading = false;
        state.fields.push(action.payload);
        state.error = null;
      })
      .addCase(createField.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // フィールド更新
      .addCase(updateField.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateField.fulfilled, (state, action: PayloadAction<Field>) => {
        state.loading = false;
        const index = state.fields.findIndex(
          (field) => field.id === action.payload.id,
        );
        if (index !== -1) {
          state.fields[index] = action.payload;
        }
        if (state.currentField?.id === action.payload.id) {
          state.currentField = action.payload;
        }
        state.error = null;
      })
      .addCase(updateField.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      })
      // フィールド削除
      .addCase(deleteField.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(
        deleteField.fulfilled,
        (state, action: PayloadAction<number>) => {
          state.loading = false;
          state.fields = state.fields.filter(
            (field) => field.id !== action.payload,
          );
          if (state.currentField?.id === action.payload) {
            state.currentField = null;
          }
          state.error = null;
        },
      )
      .addCase(deleteField.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload as string;
      });
  },
});

export const { clearError, clearCurrentField } = fieldSlice.actions;
export default fieldSlice.reducer;
