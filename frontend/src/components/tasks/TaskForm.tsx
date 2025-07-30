import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Alert,
  Box,
} from '@mui/material';
import { Task, TaskType, TaskStatus } from '../../types';
import { useAppSelector, useAppDispatch } from '../../store/hooks';
import { createTask, updateTask, clearError } from '../../store/slices/taskSlice';
import { fetchFields } from '../../store/slices/fieldSlice';

interface TaskFormProps {
  open: boolean;
  onClose: () => void;
  task?: Task | null;
}

const TaskForm: React.FC<TaskFormProps> = ({ open, onClose, task }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.tasks);
  const { fields } = useAppSelector((state) => state.fields);

  const [formData, setFormData] = useState({
    fieldId: '',
    taskType: '',
    assignedWorker: '',
    startDate: '',
    endDate: '',
    status: '',
    notes: '',
  });

  const isEdit = !!task;

  useEffect(() => {
    // フィールド一覧を取得
    dispatch(fetchFields({}));
  }, [dispatch]);

  useEffect(() => {
    if (task) {
      setFormData({
        fieldId: task.fieldId.toString(),
        taskType: task.taskType,
        assignedWorker: task.assignedWorker,
        startDate: task.startDate,
        endDate: task.endDate,
        status: task.status,
        notes: task.notes || '',
      });
    } else {
      setFormData({
        fieldId: '',
        taskType: '',
        assignedWorker: '',
        startDate: '',
        endDate: '',
        status: '',
        notes: '',
      });
    }
  }, [task]);

  useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement> | { target: { name: string; value: string } }) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const selectedField = fields.find(f => f.id.toString() === formData.fieldId);
    if (!selectedField) {
      return;
    }

    const taskData = {
      fieldId: parseInt(formData.fieldId),
      fieldName: selectedField.name,
      taskType: formData.taskType as TaskType,
      assignedWorker: formData.assignedWorker,
      startDate: formData.startDate,
      endDate: formData.endDate,
      status: formData.status as TaskStatus,
      notes: formData.notes || undefined,
    };

    if (isEdit && task) {
      await dispatch(updateTask({ id: task.id, task: taskData }));
    } else {
      await dispatch(createTask(taskData));
    }

    if (!error) {
      onClose();
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {isEdit ? 'タスク編集' : '新規タスク作成'}
      </DialogTitle>
      
      <form onSubmit={handleSubmit}>
        <DialogContent>
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr' }, gap: 2 }}>
            <FormControl fullWidth margin="normal">
              <InputLabel>フィールド</InputLabel>
              <Select
                name="fieldId"
                value={formData.fieldId}
                onChange={handleChange}
                label="フィールド"
                required
              >
                <MenuItem value="">
                  <em>選択してください</em>
                </MenuItem>
                {fields.map((field) => (
                  <MenuItem key={field.id} value={field.id.toString()}>
                    {field.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <FormControl fullWidth margin="normal">
              <InputLabel>タスクタイプ</InputLabel>
              <Select
                name="taskType"
                value={formData.taskType}
                onChange={handleChange}
                label="タスクタイプ"
                required
              >
                {Object.values(TaskType).map((type) => (
                  <MenuItem key={type} value={type}>
                    {type}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <TextField
              fullWidth
              label="担当者"
              name="assignedWorker"
              value={formData.assignedWorker}
              onChange={handleChange}
              required
              margin="normal"
            />

            <TextField
              fullWidth
              label="開始日"
              name="startDate"
              type="date"
              value={formData.startDate}
              onChange={handleChange}
              required
              margin="normal"
              InputLabelProps={{ shrink: true }}
            />

            <TextField
              fullWidth
              label="終了日"
              name="endDate"
              type="date"
              value={formData.endDate}
              onChange={handleChange}
              required
              margin="normal"
              InputLabelProps={{ shrink: true }}
            />

            <FormControl fullWidth margin="normal">
              <InputLabel>ステータス</InputLabel>
              <Select
                name="status"
                value={formData.status}
                onChange={handleChange}
                label="ステータス"
                required
              >
                {Object.values(TaskStatus).map((status) => (
                  <MenuItem key={status} value={status}>
                    {status}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            <TextField
              fullWidth
              label="備考"
              name="notes"
              value={formData.notes}
              onChange={handleChange}
              multiline
              rows={3}
              margin="normal"
              sx={{ gridColumn: { xs: '1', sm: '1 / -1' } }}
            />
          </Box>
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

export default TaskForm; 