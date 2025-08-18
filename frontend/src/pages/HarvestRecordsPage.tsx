import React, { useEffect, useState } from "react";
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  IconButton,
  CardActions,
} from "@mui/material";
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from "@mui/icons-material";
import { useAppSelector, useAppDispatch } from "../store/hooks";
import { fetchHarvestRecords } from "../store/slices/harvestRecordSlice";
import { HarvestRecord } from "../types";
import HarvestRecordForm from "../components/harvest-records/HarvestRecordForm";
import DeleteHarvestRecordDialog from "../components/harvest-records/DeleteHarvestRecordDialog";

const HarvestRecordsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { harvestRecords, loading } = useAppSelector(
    (state) => state.harvestRecords,
  );

  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedRecord, setSelectedRecord] = useState<HarvestRecord | null>(
    null,
  );

  useEffect(() => {
    dispatch(fetchHarvestRecords());
  }, [dispatch]);

  const handleCreate = () => {
    setSelectedRecord(null);
    setFormOpen(true);
  };

  const handleEdit = (record: HarvestRecord) => {
    setSelectedRecord(record);
    setFormOpen(true);
  };

  const handleDelete = (record: HarvestRecord) => {
    setSelectedRecord(record);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedRecord(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedRecord(null);
  };

  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="400px"
        sx={{
          background:
            "linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)",
          minHeight: "100vh",
        }}
      >
        <CircularProgress sx={{ color: "#fbbf24" }} />
      </Box>
    );
  }

  return (
    <Box
      sx={{
        p: 3,
        background:
          "linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)",
        minHeight: "100vh",
      }}
    >
      <Box sx={{ maxWidth: 1400, mx: "auto" }}>
        <Box
          display="flex"
          justifyContent="space-between"
          alignItems="center"
          sx={{ mb: 4 }}
        >
          <Typography
            variant="h3"
            component="h1"
            sx={{
              fontWeight: 700,
              color: "#fbbf24",
              textShadow: "0 2px 4px rgba(0,0,0,0.3)",
            }}
          >
            🌾 収穫記録
          </Typography>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            size="large"
            onClick={handleCreate}
            sx={{
              background: "linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%)",
              boxShadow: "0 4px 15px rgba(251, 191, 36, 0.3)",
              "&:hover": {
                background: "linear-gradient(135deg, #f59e0b 0%, #d97706 100%)",
                boxShadow: "0 6px 20px rgba(251, 191, 36, 0.4)",
              },
            }}
          >
            新規記録
          </Button>
        </Box>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: {
              xs: "1fr",
              sm: "repeat(2, 1fr)",
              md: "repeat(3, 1fr)",
            },
            gap: 3,
          }}
        >
          {harvestRecords.map((record) => (
            <Card
              key={record.id}
              sx={{
                height: "100%",
                background: "linear-gradient(135deg, #1e293b 0%, #334155 100%)",
                borderRadius: 3,
                boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                border: "1px solid #475569",
                transition: "all 0.3s ease",
                "&:hover": {
                  transform: "translateY(-4px)",
                  boxShadow: "0 12px 40px rgba(0,0,0,0.4)",
                  border: "1px solid #64748b",
                },
              }}
            >
              <CardContent sx={{ p: 3 }}>
                <Typography
                  variant="h6"
                  gutterBottom
                  sx={{
                    fontWeight: 600,
                    color: "#f1f5f9",
                  }}
                >
                  {record.fieldName}
                </Typography>
                <Typography
                  variant="body2"
                  sx={{
                    mb: 2,
                    color: "#94a3b8",
                  }}
                >
                  📅 {record.harvestDate}
                </Typography>

                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${record.quantityKg}kg`}
                    size="small"
                    sx={{
                      backgroundColor: "#4ade80",
                      color: "#1e293b",
                      fontWeight: 600,
                    }}
                  />
                  <Chip
                    label={record.teaGrade}
                    size="small"
                    sx={{
                      backgroundColor:
                        record.teaGrade === "PREMIUM"
                          ? "#fbbf24"
                          : record.teaGrade === "HIGH"
                            ? "#60a5fa"
                            : record.teaGrade === "MEDIUM"
                              ? "#a78bfa"
                              : "#f87171",
                      color: "#1e293b",
                      fontWeight: 600,
                    }}
                  />
                </Box>

                {record.notes && (
                  <Typography
                    variant="body2"
                    sx={{
                      color: "#cbd5e1",
                      fontStyle: "italic",
                    }}
                  >
                    {record.notes}
                  </Typography>
                )}
              </CardContent>

              <CardActions sx={{ justifyContent: "flex-end", p: 2 }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(record)}
                  sx={{
                    color: "#60a5fa",
                    "&:hover": {
                      backgroundColor: "rgba(96, 165, 250, 0.1)",
                    },
                  }}
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => handleDelete(record)}
                  sx={{
                    color: "#f87171",
                    "&:hover": {
                      backgroundColor: "rgba(248, 113, 113, 0.1)",
                    },
                  }}
                >
                  <DeleteIcon />
                </IconButton>
              </CardActions>
            </Card>
          ))}
        </Box>

        {harvestRecords.length === 0 && (
          <Box textAlign="center" py={6}>
            <Typography
              variant="h5"
              sx={{
                color: "#94a3b8",
                fontWeight: 500,
                mb: 2,
              }}
            >
              📭 収穫記録が登録されていません
            </Typography>
            <Typography
              variant="body1"
              sx={{
                color: "#64748b",
                fontStyle: "italic",
              }}
            >
              新規収穫記録を追加してください
            </Typography>
          </Box>
        )}

        {/* フォームダイアログ */}
        <HarvestRecordForm
          open={formOpen}
          onClose={handleFormClose}
          record={selectedRecord}
        />

        {/* 削除確認ダイアログ */}
        <DeleteHarvestRecordDialog
          open={deleteDialogOpen}
          onClose={handleDeleteDialogClose}
          record={selectedRecord}
        />
      </Box>
    </Box>
  );
};

export default HarvestRecordsPage;
