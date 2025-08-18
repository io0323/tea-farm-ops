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
import { Field } from "../../types";
import { useAppSelector, useAppDispatch } from "../../store/hooks";
import {
  createField,
  updateField,
  clearError,
} from "../../store/slices/fieldSlice";

interface FieldFormProps {
  open: boolean;
  onClose: () => void;
  field?: Field | null;
}

const soilTypes = ["砂質土", "粘土質土", "ローム質土", "火山灰土", "その他"];

const FieldForm: React.FC<FieldFormProps> = ({ open, onClose, field }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.fields);

  const [formData, setFormData] = useState({
    name: "",
    location: "",
    areaSize: "",
    soilType: "",
    notes: "",
  });

  const isEdit = !!field;

  useEffect(() => {
    if (field) {
      setFormData({
        name: field.name,
        location: field.location,
        areaSize: field.areaSize.toString(),
        soilType: field.soilType || "",
        notes: field.notes || "",
      });
    } else {
      setFormData({
        name: "",
        location: "",
        areaSize: "",
        soilType: "",
        notes: "",
      });
    }
  }, [field]);

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

    const fieldData = {
      name: formData.name,
      location: formData.location,
      areaSize: parseFloat(formData.areaSize),
      soilType: formData.soilType || undefined,
      notes: formData.notes || undefined,
    };

    if (isEdit && field) {
      await dispatch(updateField({ id: field.id, field: fieldData }));
    } else {
      await dispatch(createField(fieldData));
    }

    if (!error) {
      onClose();
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {isEdit ? "フィールド編集" : "新規フィールド作成"}
      </DialogTitle>

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
            <TextField
              fullWidth
              label="フィールド名"
              name="name"
              value={formData.name}
              onChange={handleChange}
              required
              margin="normal"
            />

            <TextField
              fullWidth
              label="場所"
              name="location"
              value={formData.location}
              onChange={handleChange}
              required
              margin="normal"
            />

            <TextField
              fullWidth
              label="面積 (ha)"
              name="areaSize"
              type="number"
              value={formData.areaSize}
              onChange={handleChange}
              required
              margin="normal"
              inputProps={{ min: 0, step: 0.1 }}
            />

            <FormControl fullWidth margin="normal">
              <InputLabel>土壌タイプ</InputLabel>
              <Select
                name="soilType"
                value={formData.soilType}
                onChange={handleChange}
                label="土壌タイプ"
              >
                <MenuItem value="">
                  <em>選択してください</em>
                </MenuItem>
                {soilTypes.map((type) => (
                  <MenuItem key={type} value={type}>
                    {type}
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

export default FieldForm;
