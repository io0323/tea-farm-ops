import React from 'react';
import {
  Box,
  Pagination as MuiPagination,
  FormControl,
  Select,
  MenuItem,
  Typography,
  SelectChangeEvent,
} from '@mui/material';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  pageSize: number;
  totalItems: number;
  onPageChange: (page: number) => void;
  onPageSizeChange: (pageSize: number) => void;
}

const pageSizeOptions = [10, 25, 50, 100];

const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  totalPages,
  pageSize,
  totalItems,
  onPageChange,
  onPageSizeChange,
}) => {
  const handlePageChange = (event: React.ChangeEvent<unknown>, page: number) => {
    onPageChange(page);
  };

  const handlePageSizeChange = (event: SelectChangeEvent<number>) => {
    onPageSizeChange(event.target.value as number);
  };

  const startItem = (currentPage - 1) * pageSize + 1;
  const endItem = Math.min(currentPage * pageSize, totalItems);

  return (
    <Box
      display="flex"
      justifyContent="space-between"
      alignItems="center"
      sx={{ mt: 3, p: 2, backgroundColor: 'background.paper', borderRadius: 1 }}
    >
      <Box display="flex" alignItems="center" gap={2}>
        <Typography variant="body2" color="text.secondary">
          {totalItems > 0 ? `${startItem}-${endItem} / ${totalItems}件` : '0件'}
        </Typography>
        
        <FormControl size="small" sx={{ minWidth: 80 }}>
          <Select
            value={pageSize}
            onChange={handlePageSizeChange}
            displayEmpty
          >
            {pageSizeOptions.map((size) => (
              <MenuItem key={size} value={size}>
                {size}件
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>

      {totalPages > 1 && (
        <MuiPagination
          count={totalPages}
          page={currentPage}
          onChange={handlePageChange}
          showFirstButton
          showLastButton
          size="small"
        />
      )}
    </Box>
  );
};

export default Pagination; 