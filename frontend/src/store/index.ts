import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import fieldReducer from './slices/fieldSlice';
import taskReducer from './slices/taskSlice';
import harvestRecordReducer from './slices/harvestRecordSlice';
import weatherObservationReducer from './slices/weatherObservationSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    fields: fieldReducer,
    tasks: taskReducer,
    harvestRecords: harvestRecordReducer,
    weatherObservations: weatherObservationReducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch; 