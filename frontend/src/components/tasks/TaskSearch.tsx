import React, { useState } from "react";
import {
  Card,
  CardContent,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  Box,
  Typography,
} from "@mui/material";
import { Search as SearchIcon, Clear as ClearIcon } from "@mui/icons-material";
import { TaskType, TaskStatus } from "../../types";

interface TaskSearchProps {
  onSearch: (filters: TaskFilters) => void;
  onClear: () => void;
}

export interface TaskFilters {
  taskType?: string;
  status?: string;
  assignedWorker?: string;
}

const TaskSearch: React.FC<TaskSearchProps> = ({ onSearch, onClear }) => {
  const [filters, setFilters] = useState<TaskFilters>({
    taskType: "",
    status: "",
    assignedWorker: "",
  });

  const handleChange = (field: keyof TaskFilters, value: string) => {
    setFilters((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSearch = () => {
    const activeFilters = Object.fromEntries(
      Object.entries(filters).filter(
        ([_, value]) => value && value.trim() !== "",
      ),
    );
    onSearch(activeFilters);
  };

  const handleClear = () => {
    setFilters({
      taskType: "",
      status: "",
      assignedWorker: "",
    });
    onClear();
  };

  const hasActiveFilters = Object.values(filters).some(
    (value) => value && value.trim() !== "",
  );

  return (
    <Card sx={{ mb: 3 }}>
      <CardContent>
        <Typography variant="h6" sx={{ mb: 2 }}>
          タスク検索
        </Typography>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", sm: "repeat(4, 1fr)" },
            gap: 2,
            alignItems: "center",
          }}
        >
          <FormControl fullWidth size="small">
            <InputLabel>タスクタイプ</InputLabel>
            <Select
              value={filters.taskType}
              onChange={(e) => handleChange("taskType", e.target.value)}
              label="タスクタイプ"
            >
              <MenuItem value="">
                <em>すべて</em>
              </MenuItem>
              {Object.values(TaskType).map((type) => (
                <MenuItem key={type} value={type}>
                  {type}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <FormControl fullWidth size="small">
            <InputLabel>ステータス</InputLabel>
            <Select
              value={filters.status}
              onChange={(e) => handleChange("status", e.target.value)}
              label="ステータス"
            >
              <MenuItem value="">
                <em>すべて</em>
              </MenuItem>
              {Object.values(TaskStatus).map((status) => (
                <MenuItem key={status} value={status}>
                  {status}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <TextField
            fullWidth
            label="担当者"
            value={filters.assignedWorker}
            onChange={(e) => handleChange("assignedWorker", e.target.value)}
            size="small"
          />

          <Box display="flex" gap={1}>
            <Button
              variant="contained"
              startIcon={<SearchIcon />}
              onClick={handleSearch}
              disabled={!hasActiveFilters}
              size="small"
            >
              検索
            </Button>
            <Button
              variant="outlined"
              startIcon={<ClearIcon />}
              onClick={handleClear}
              disabled={!hasActiveFilters}
              size="small"
            >
              クリア
            </Button>
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
};

export default TaskSearch;
