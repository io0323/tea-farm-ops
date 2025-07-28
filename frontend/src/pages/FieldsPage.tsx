import React, { useEffect, useState, useMemo } from 'react';
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Grid,
  Chip,
  CircularProgress,
  IconButton,
  CardActions,
} from '@mui/material';
import { 
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  FileDownload as ExportIcon,
} from '@mui/icons-material';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { fetchFields } from '../store/slices/fieldSlice';
import { Field } from '../types';
import FieldForm from '../components/fields/FieldForm';
import DeleteFieldDialog from '../components/fields/DeleteFieldDialog';
import FieldSearch, { FieldFilters } from '../components/fields/FieldSearch';
import Pagination from '../components/common/Pagination';
import { exportFieldsToCSV } from '../utils/exportUtils';

const FieldsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { fields, loading } = useAppSelector((state) => state.fields);
  
  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedField, setSelectedField] = useState<Field | null>(null);
  const [searchFilters, setSearchFilters] = useState<FieldFilters>({});
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(12);

  useEffect(() => {
    dispatch(fetchFields());
  }, [dispatch]);

  // フィルタリングされたフィールド
  const filteredFields = useMemo(() => {
    return fields.filter(field => {
      if (searchFilters.name && !field.name.toLowerCase().includes(searchFilters.name.toLowerCase())) {
        return false;
      }
      if (searchFilters.location && !field.location.toLowerCase().includes(searchFilters.location.toLowerCase())) {
        return false;
      }
      if (searchFilters.soilType && field.soilType !== searchFilters.soilType) {
        return false;
      }
      return true;
    });
  }, [fields, searchFilters]);

  // ページネーションされたフィールド
  const paginatedFields = useMemo(() => {
    const startIndex = (currentPage - 1) * pageSize;
    const endIndex = startIndex + pageSize;
    return filteredFields.slice(startIndex, endIndex);
  }, [filteredFields, currentPage, pageSize]);

  const totalPages = Math.ceil(filteredFields.length / pageSize);

  const handleCreate = () => {
    setSelectedField(null);
    setFormOpen(true);
  };

  const handleEdit = (field: Field) => {
    setSelectedField(field);
    setFormOpen(true);
  };

  const handleDelete = (field: Field) => {
    setSelectedField(field);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedField(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedField(null);
  };

  const handleSearch = (filters: FieldFilters) => {
    setSearchFilters(filters);
    setCurrentPage(1); // 検索時は最初のページに戻る
  };

  const handleClearSearch = () => {
    setSearchFilters({});
    setCurrentPage(1);
  };

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const handlePageSizeChange = (newPageSize: number) => {
    setPageSize(newPageSize);
    setCurrentPage(1);
  };

  const handleExport = () => {
    exportFieldsToCSV(fields);
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" sx={{ mb: 3 }}>
        <Typography variant="h4" component="h1">
          フィールド管理
        </Typography>
        <Box display="flex" gap={1}>
          <Button
            variant="outlined"
            startIcon={<ExportIcon />}
            onClick={handleExport}
            disabled={fields.length === 0}
          >
            エクスポート
          </Button>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            size="large"
            onClick={handleCreate}
          >
            新規フィールド
          </Button>
        </Box>
      </Box>

      {/* 検索フィルター */}
      <FieldSearch onSearch={handleSearch} onClear={handleClearSearch} />

      {/* 検索結果表示 */}
      {Object.keys(searchFilters).length > 0 && (
        <Box sx={{ mb: 2 }}>
          <Typography variant="body2" color="text.secondary">
            検索結果: {filteredFields.length}件
          </Typography>
        </Box>
      )}

      <Grid container spacing={3}>
        {paginatedFields.map((field) => (
          <Grid item xs={12} sm={6} md={4} key={field.id}>
            <Card sx={{ height: '100%' }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  {field.name}
                </Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  {field.location}
                </Typography>
                
                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${field.areaSize}ha`}
                    size="small"
                    color="primary"
                  />
                  {field.soilType && (
                    <Chip
                      label={field.soilType}
                      size="small"
                      variant="outlined"
                    />
                  )}
                </Box>

                {field.notes && (
                  <Typography variant="body2" color="text.secondary">
                    {field.notes}
                  </Typography>
                )}
              </CardContent>
              
              <CardActions sx={{ justifyContent: 'flex-end' }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(field)}
                  color="primary"
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => handleDelete(field)}
                  color="error"
                >
                  <DeleteIcon />
                </IconButton>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>

      {filteredFields.length === 0 && (
        <Box textAlign="center" py={4}>
          <Typography variant="h6" color="text.secondary">
            {Object.keys(searchFilters).length > 0 ? '検索条件に一致するフィールドがありません' : 'フィールドが登録されていません'}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {Object.keys(searchFilters).length > 0 ? '検索条件を変更してください' : '新規フィールドを追加してください'}
          </Typography>
        </Box>
      )}

      {/* ページネーション */}
      {filteredFields.length > 0 && (
        <Pagination
          currentPage={currentPage}
          totalPages={totalPages}
          pageSize={pageSize}
          totalItems={filteredFields.length}
          onPageChange={handlePageChange}
          onPageSizeChange={handlePageSizeChange}
        />
      )}

      {/* フォームダイアログ */}
      <FieldForm
        open={formOpen}
        onClose={handleFormClose}
        field={selectedField}
      />

      {/* 削除確認ダイアログ */}
      <DeleteFieldDialog
        open={deleteDialogOpen}
        onClose={handleDeleteDialogClose}
        field={selectedField}
      />
    </Box>
  );
};

export default FieldsPage; 