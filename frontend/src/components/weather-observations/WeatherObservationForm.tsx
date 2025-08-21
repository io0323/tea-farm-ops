import React, { useState, useEffect } from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Alert,
  Box,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from "@mui/material";
import { WeatherObservation } from "../../types";
import { useAppSelector, useAppDispatch } from "../../store/hooks";
import {
  createWeatherObservation,
  updateWeatherObservation,
  clearError,
} from "../../store/slices/weatherObservationSlice";
import { fetchFields } from "../../store/slices/fieldSlice";

interface WeatherObservationFormProps {
  open: boolean;
  onClose: () => void;
  observation?: WeatherObservation | null;
}

const WeatherObservationForm: React.FC<WeatherObservationFormProps> = ({
  open,
  onClose,
  observation,
}) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector(
    (state) => state.weatherObservations,
  );
  const { fields } = useAppSelector((state) => state.fields);

  const [formData, setFormData] = useState({
    fieldId: "",
    date: "",
    temperature: "",
    rainfall: "",
    humidity: "",
    pestsSeen: "",
    notes: "",
  });

  const isEdit = !!observation;

  useEffect(() => {
    // フィールド一覧を取得
    dispatch(fetchFields({}));
  }, [dispatch]);

  useEffect(() => {
    if (observation) {
      setFormData({
        fieldId: observation.fieldId.toString(),
        date: observation.date,
        temperature: observation.temperature.toString(),
        rainfall: observation.rainfall.toString(),
        humidity: observation.humidity.toString(),
        pestsSeen: observation.pestsSeen || "",
        notes: observation.notes || "",
      });
    } else {
      setFormData({
        fieldId: "",
        date: "",
        temperature: "",
        rainfall: "",
        humidity: "",
        pestsSeen: "",
        notes: "",
      });
    }
  }, [observation]);

  useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleChange = (
    e:
      | React.ChangeEvent<HTMLInputElement>
      | { target: { name: string; value: string } },
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const selectedField = fields.find(
      (f) => f.id.toString() === formData.fieldId,
    );
    if (!selectedField) {
      return;
    }

    const observationData = {
      fieldId: parseInt(formData.fieldId),
      fieldName: selectedField.name,
      date: formData.date,
      temperature: parseFloat(formData.temperature),
      rainfall: parseFloat(formData.rainfall),
      humidity: parseFloat(formData.humidity),
      pestsSeen: formData.pestsSeen || undefined,
      notes: formData.notes || undefined,
    };

    if (isEdit && observation) {
      await dispatch(
        updateWeatherObservation({
          id: observation.id,
          observation: observationData,
        }),
      );
    } else {
      await dispatch(createWeatherObservation(observationData));
    }

    if (!error) {
      onClose();
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>{isEdit ? "天候観測編集" : "新規天候観測作成"}</DialogTitle>

      <form onSubmit={handleSubmit}>
        <DialogContent>
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Box
            sx={{
              display: "grid",
              gridTemplateColumns: { xs: "1fr", sm: "1fr 1fr" },
              gap: 2,
            }}
          >
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

            <TextField
              fullWidth
              label="観測日"
              name="date"
              type="date"
              value={formData.date}
              onChange={handleChange}
              required
              margin="normal"
              InputLabelProps={{ shrink: true }}
            />

            <TextField
              fullWidth
              label="気温 (°C)"
              name="temperature"
              type="number"
              value={formData.temperature}
              onChange={handleChange}
              required
              margin="normal"
              inputProps={{ min: -50, max: 50, step: 0.1 }}
            />

            <TextField
              fullWidth
              label="降水量 (mm)"
              name="rainfall"
              type="number"
              value={formData.rainfall}
              onChange={handleChange}
              required
              margin="normal"
              inputProps={{ min: 0, step: 0.1 }}
            />

            <TextField
              fullWidth
              label="湿度 (%)"
              name="humidity"
              type="number"
              value={formData.humidity}
              onChange={handleChange}
              required
              margin="normal"
              inputProps={{ min: 0, max: 100, step: 0.1 }}
            />

            <TextField
              fullWidth
              label="害虫の有無"
              name="pestsSeen"
              value={formData.pestsSeen}
              onChange={handleChange}
              margin="normal"
              placeholder="例: アブラムシ、カメムシなど"
              sx={{ gridColumn: { xs: "1", sm: "1 / -1" } }}
            />

            <TextField
              fullWidth
              label="備考"
              name="notes"
              value={formData.notes}
              onChange={handleChange}
              multiline
              rows={3}
              margin="normal"
              sx={{ gridColumn: { xs: "1", sm: "1 / -1" } }}
            />
          </Box>
        </DialogContent>

        <DialogActions>
          <Button onClick={onClose}>キャンセル</Button>
          <Button type="submit" variant="contained" disabled={loading}>
            {loading ? "保存中..." : isEdit ? "更新" : "作成"}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

export default WeatherObservationForm;
