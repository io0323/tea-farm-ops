import React from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Alert,
} from "@mui/material";
import { HarvestRecord } from "../../types";
import { useAppSelector, useAppDispatch } from "../../store/hooks";
import {
  deleteHarvestRecord,
  clearError,
} from "../../store/slices/harvestRecordSlice";

interface DeleteHarvestRecordDialogProps {
  open: boolean;
  onClose: () => void;
  record: HarvestRecord | null;
}

const DeleteHarvestRecordDialog: React.FC<DeleteHarvestRecordDialogProps> = ({
  open,
  onClose,
  record,
}) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.harvestRecords);

  React.useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleDelete = async () => {
    if (record) {
      await dispatch(deleteHarvestRecord(record.id));
      if (!error) {
        onClose();
      }
    }
  };

  if (!record) return null;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>収穫記録削除確認</DialogTitle>

      <DialogContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Typography variant="body1" sx={{ mb: 2 }}>
          以下の収穫記録を削除しますか？
        </Typography>

        <Typography variant="h6" sx={{ mb: 1 }}>
          {record.teaGrade} - {record.quantityKg}kg
        </Typography>

        <Typography variant="body2" color="text.secondary">
          収穫日: {record.harvestDate}
          <br />
          茶葉グレード: {record.teaGrade}
          <br />
          収穫量: {record.quantityKg}kg
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
          {loading ? "削除中..." : "削除"}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default DeleteHarvestRecordDialog;
