import React, { useState, useEffect } from "react";
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
} from "@mui/material";
import { HarvestRecord, TeaGrade } from "../../types";
import { useAppSelector, useAppDispatch } from "../../store/hooks";
import {
  createHarvestRecord,
  updateHarvestRecord,
  clearError,
} from "../../store/slices/harvestRecordSlice";
import { fetchFields } from "../../store/slices/fieldSlice";

interface HarvestRecordFormProps {
  open: boolean;
  onClose: () => void;
  record?: HarvestRecord | null;
}

const HarvestRecordForm: React.FC<HarvestRecordFormProps> = ({
  open,
  onClose,
  record,
}) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.harvestRecords);
  const { fields } = useAppSelector((state) => state.fields);

  const [formData, setFormData] = useState({
    fieldId: "",
    harvestDate: "",
    quantityKg: "",
    teaGrade: "",
    notes: "",
  });

  const isEdit = !!record;

  useEffect(() => {
    // フィールド一覧を取得
    dispatch(fetchFields({}));
  }, [dispatch]);

  useEffect(() => {
    if (record) {
      setFormData({
        fieldId: record.fieldId.toString(),
        harvestDate: record.harvestDate,
        quantityKg: record.quantityKg.toString(),
        teaGrade: record.teaGrade,
        notes: record.notes || "",
      });
    } else {
      setFormData({
        fieldId: "",
        harvestDate: "",
        quantityKg: "",
        teaGrade: "",
        notes: "",
      });
    }
  }, [record]);

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

    const recordData = {
      fieldId: parseInt(formData.fieldId),
      fieldName: selectedField.name,
      harvestDate: formData.harvestDate,
      quantityKg: parseFloat(formData.quantityKg),
      teaGrade: formData.teaGrade as TeaGrade,
      notes: formData.notes || undefined,
    };

    if (isEdit && record) {
      await dispatch(
        updateHarvestRecord({ id: record.id, record: recordData }),
      );
    } else {
      await dispatch(createHarvestRecord(recordData));
    }

    if (!error) {
      onClose();
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>{isEdit ? "収穫記録編集" : "新規収穫記録作成"}</DialogTitle>

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
              label="収穫日"
              name="harvestDate"
              type="date"
              value={formData.harvestDate}
              onChange={handleChange}
              required
              margin="normal"
              InputLabelProps={{ shrink: true }}
            />

            <TextField
              fullWidth
              label="収穫量 (kg)"
              name="quantityKg"
              type="number"
              value={formData.quantityKg}
              onChange={handleChange}
              required
              margin="normal"
              inputProps={{ min: 0, step: 0.1 }}
            />

            <FormControl fullWidth margin="normal">
              <InputLabel>茶葉グレード</InputLabel>
              <Select
                name="teaGrade"
                value={formData.teaGrade}
                onChange={handleChange}
                label="茶葉グレード"
                required
              >
                {Object.values(TeaGrade).map((grade) => (
                  <MenuItem key={grade} value={grade}>
                    {grade}
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

export default HarvestRecordForm;
