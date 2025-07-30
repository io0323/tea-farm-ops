import React, { useState } from 'react';
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
} from '@mui/material';
import { Search as SearchIcon, Clear as ClearIcon } from '@mui/icons-material';

interface FieldSearchProps {
  onSearch: (filters: FieldFilters) => void;
  onClear: () => void;
}

export interface FieldFilters {
  name?: string;
  location?: string;
  soilType?: string;
}

const soilTypes = [
  '砂質土',
  '粘土質土',
  'ローム質土',
  '火山灰土',
  'その他',
];

const FieldSearch: React.FC<FieldSearchProps> = ({ onSearch, onClear }) => {
  const [filters, setFilters] = useState<FieldFilters>({
    name: '',
    location: '',
    soilType: '',
  });

  const handleChange = (field: keyof FieldFilters, value: string) => {
    setFilters(prev => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSearch = () => {
    const activeFilters = Object.fromEntries(
      Object.entries(filters).filter(([_, value]) => value && value.trim() !== '')
    );
    onSearch(activeFilters);
  };

  const handleClear = () => {
    setFilters({
      name: '',
      location: '',
      soilType: '',
    });
    onClear();
  };

  const hasActiveFilters = Object.values(filters).some(value => value && value.trim() !== '');

  return (
    <Card sx={{ mb: 3 }}>
      <CardContent>
        <Typography variant="h6" sx={{ mb: 2 }}>
          フィールド検索
        </Typography>
        
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(4, 1fr)' }, gap: 2, alignItems: 'center' }}>
          <TextField
            fullWidth
            label="フィールド名"
            value={filters.name}
            onChange={(e) => handleChange('name', e.target.value)}
            size="small"
          />
          
          <TextField
            fullWidth
            label="場所"
            value={filters.location}
            onChange={(e) => handleChange('location', e.target.value)}
            size="small"
          />
          
          <FormControl fullWidth size="small">
            <InputLabel>土壌タイプ</InputLabel>
            <Select
              value={filters.soilType}
              onChange={(e) => handleChange('soilType', e.target.value)}
              label="土壌タイプ"
            >
              <MenuItem value="">
                <em>すべて</em>
              </MenuItem>
              {soilTypes.map((type) => (
                <MenuItem key={type} value={type}>
                  {type}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
          
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

export default FieldSearch; 