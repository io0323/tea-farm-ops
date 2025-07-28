import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Alert,
} from '@mui/material';
import { HarvestRecord, TeaGrade } from '../../types';
import { useAppSelector, useAppDispatch } from '../../store/hooks';
import { createHarvestRecord, updateHarvestRecord, clearError } from '../../store/slices/harvestRecordSlice';

interface HarvestRecordFormProps {
  open: boolean;
  onClose: () => void;
  record?: HarvestRecord | null;
}

const HarvestRecordForm: React.FC<HarvestRecordFormProps> = ({ open, onClose, record }) => {
  const dispatch = useAppDispatch();
  const { loading, error } = useAppSelector((state) => state.harvestRecords);

  const [formData, setFormData] = useState({
    harvestDate: '',
    quantityKg: '',
    teaGrade: '',
    notes: '',
  });

  const isEdit = !!record;

  useEffect(() => {
    if (record) {
      setFormData({
        harvestDate: record.harvestDate,
        quantityKg: record.quantityKg.toString(),
        teaGrade: record.teaGrade,
        notes: record.notes || '',
      });
    } else {
      setFormData({
        harvestDate: '',
        quantityKg: '',
        teaGrade: '',
        notes: '',
      });
    }
  }, [record]);

  useEffect(() => {
    if (!open) {
      dispatch(clearError());
    }
  }, [open, dispatch]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | { name?: string; value: unknown }>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name as string]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const recordData = {
      harvestDate: formData.harvestDate,
      quantityKg: parseFloat(formData.quantityKg),
      teaGrade: formData.teaGrade as TeaGrade,
      notes: formData.notes || undefined,
    };

    if (isEdit && record) {
      await dispatch(updateHarvestRecord({ id: record.id, record: recordData }));
    } else {
      await dispatch(createHarvestRecord(recordData));
    }

    if (!error) {
      onClose();
    }
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle>
        {isEdit ? '収穫記録編集' : '新規収穫記録作成'}
      </DialogTitle>
      
      <form onSubmit={handleSubmit}>
        <DialogContent>
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
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
            </Grid>

            <Grid item xs={12} sm={6}>
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
            </Grid>

            <Grid item xs={12} sm={6}>
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
            </Grid>

            <Grid item xs={12}>
              <TextField
                fullWidth
                label="備考"
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                multiline
                rows={3}
                margin="normal"
              />
            </Grid>
          </Grid>
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

export default HarvestRecordForm; 