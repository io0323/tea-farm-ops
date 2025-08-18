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
import { WeatherObservation } from "../../types";
import { useAppSelector, useAppDispatch } from "../../store/hooks";
import {
  deleteWeatherObservation,
  clearError,
} from "../../store/slices/weatherObservationSlice";

interface DeleteWeatherObservationDialogProps {
  open: boolean;
  onClose: () => void;
  observation: WeatherObservation | null;
}

const DeleteWeatherObservationDialog: React.FC<
  DeleteWeatherObservationDialogProps
> = ({ open, onClose, observation }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector(
    (state) => state.weatherObservations,
  );

  React.useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleDelete = async () => {
    if (observation) {
      await dispatch(deleteWeatherObservation(observation.id));
      if (!error) {
        onClose();
      }
    }
  };

  if (!observation) return null;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>天候観測削除確認</DialogTitle>

      <DialogContent>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Typography variant="body1" sx={{ mb: 2 }}>
          以下の天候観測を削除しますか？
        </Typography>

        <Typography variant="h6" sx={{ mb: 1 }}>
          {observation.date}
        </Typography>

        <Typography variant="body2" color="text.secondary">
          気温: {observation.temperature}°C
          <br />
          降水量: {observation.rainfall}mm
          <br />
          湿度: {observation.humidity}%
          {observation.pestsSeen && (
            <>
              <br />
              害虫: {observation.pestsSeen}
            </>
          )}
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

export default DeleteWeatherObservationDialog;
