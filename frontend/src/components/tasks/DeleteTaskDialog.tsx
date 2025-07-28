import React from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Alert,
} from '@mui/material';
import { Task } from '../../types';
import { useAppSelector, useAppDispatch } from '../../store/hooks';
import { deleteTask, clearError } from '../../store/slices/taskSlice';

interface DeleteTaskDialogProps {
  open: boolean;
  onClose: () => void;
  task: Task | null;
}

const DeleteTaskDialog: React.FC<DeleteTaskDialogProps> = ({ open, onClose, task }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.tasks);

  React.useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleDelete = async () => {
    if (task) {
      await dispatch(deleteTask(task.id));
      if (!error) {
        onClose();
      }
    }
  };

  if (!task) return null;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        タスク削除確認
      </DialogTitle>
      
      <DialogContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Typography variant="body1" sx={{ mb: 2 }}>
          以下のタスクを削除しますか？
        </Typography>

        <Typography variant="h6" sx={{ mb: 1 }}>
          {task.taskType}
        </Typography>
        
        <Typography variant="body2" color="text.secondary">
          担当者: {task.assignedWorker}<br />
          開始日: {task.startDate}<br />
          終了日: {task.endDate}<br />
          ステータス: {task.status}
        </Typography>

        <Alert severity="warning" sx={{ mt: 2 }}>
          この操作は取り消すことができません。
        </Alert>
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose} disabled={loading}>
          キャンセル
        </Button>
        <Button
          onClick={handleDelete}
          color="error"
          variant="contained"
          disabled={loading}
        >
          {loading ? '削除中...' : '削除'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default DeleteTaskDialog; 