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
import { Field } from '../../types';
import { useAppSelector, useAppDispatch } from '../../store/hooks';
import { deleteField, clearError } from '../../store/slices/fieldSlice';

interface DeleteFieldDialogProps {
  open: boolean;
  onClose: () => void;
  field: Field | null;
}

const DeleteFieldDialog: React.FC<DeleteFieldDialogProps> = ({ open, onClose, field }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.fields);

  React.useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleDelete = async () => {
    if (field) {
      await dispatch(deleteField(field.id));
      if (!error) {
        onClose();
      }
    }
  };

  if (!field) return null;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        フィールド削除確認
      </DialogTitle>
      
      <DialogContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Typography variant="body1" sx={{ mb: 2 }}>
          以下のフィールドを削除しますか？
        </Typography>

        <Typography variant="h6" sx={{ mb: 1 }}>
          {field.name}
        </Typography>
        
        <Typography variant="body2" color="text.secondary">
          場所: {field.location}<br />
          面積: {field.areaSize}ha<br />
          {field.soilType && `土壌タイプ: ${field.soilType}`}
        </Typography>

        <Alert severity="warning" sx={{ mt: 2 }}>
          この操作は取り消すことができません。関連するタスクや収穫記録も削除される可能性があります。
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

export default DeleteFieldDialog; 