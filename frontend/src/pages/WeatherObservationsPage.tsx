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
import { fetchWeatherObservations } from "../store/slices/weatherObservationSlice";
import { WeatherObservation } from "../types";
import WeatherObservationForm from "../components/weather-observations/WeatherObservationForm";
import DeleteWeatherObservationDialog from "../components/weather-observations/DeleteWeatherObservationDialog";

const WeatherObservationsPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { weatherObservations, loading } = useAppSelector(
    (state) => state.weatherObservations,
  );

  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedObservation, setSelectedObservation] =
    useState<WeatherObservation | null>(null);

  useEffect(() => {
    // CI環境ではAPIコールをスキップ
    if (process.env.NODE_ENV === "test" || process.env.CI === "true") {
      return;
    }
    
    dispatch(fetchWeatherObservations());
  }, [dispatch]);

  const handleCreate = () => {
    setSelectedObservation(null);
    setFormOpen(true);
  };

  const handleEdit = (observation: WeatherObservation) => {
    setSelectedObservation(observation);
    setFormOpen(true);
  };

  const handleDelete = (observation: WeatherObservation) => {
    setSelectedObservation(observation);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedObservation(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedObservation(null);
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
        <CircularProgress sx={{ color: "#a78bfa" }} />
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
              color: "#a78bfa",
              textShadow: "0 2px 4px rgba(0,0,0,0.3)",
            }}
          >
            🌤️ 天候観測
          </Typography>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            size="large"
            onClick={handleCreate}
            sx={{
              background: "linear-gradient(135deg, #a78bfa 0%, #8b5cf6 100%)",
              boxShadow: "0 4px 15px rgba(167, 139, 250, 0.3)",
              "&:hover": {
                background: "linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%)",
                boxShadow: "0 6px 20px rgba(167, 139, 250, 0.4)",
              },
            }}
          >
            新規観測
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
          {weatherObservations.map((observation) => (
            <Card
              key={observation.id}
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
                  {observation.fieldName}
                </Typography>
                <Typography
                  variant="body2"
                  sx={{
                    mb: 2,
                    color: "#94a3b8",
                  }}
                >
                  📅 {observation.date}
                </Typography>

                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={`${observation.temperature}°C`}
                    size="small"
                    sx={{
                      backgroundColor:
                        observation.temperature >= 30
                          ? "#f87171"
                          : observation.temperature >= 25
                            ? "#fbbf24"
                            : observation.temperature >= 15
                              ? "#4ade80"
                              : "#60a5fa",
                      color: "#1e293b",
                      fontWeight: 600,
                    }}
                  />
                  <Chip
                    label={`${observation.rainfall}mm`}
                    size="small"
                    sx={{
                      backgroundColor:
                        observation.rainfall >= 50
                          ? "#f87171"
                          : observation.rainfall >= 20
                            ? "#fbbf24"
                            : "#60a5fa",
                      color: "#1e293b",
                      fontWeight: 600,
                    }}
                  />
                  <Chip
                    label={`${observation.humidity}%`}
                    size="small"
                    variant="outlined"
                    sx={{
                      borderColor: "#a78bfa",
                      color: "#a78bfa",
                    }}
                  />
                </Box>

                {observation.pestsSeen && (
                  <Typography
                    variant="body2"
                    sx={{
                      mb: 1,
                      color: "#fbbf24",
                      fontWeight: 500,
                    }}
                  >
                    🐛 {observation.pestsSeen}
                  </Typography>
                )}

                {observation.notes && (
                  <Typography
                    variant="body2"
                    sx={{
                      color: "#cbd5e1",
                      fontStyle: "italic",
                    }}
                  >
                    {observation.notes}
                  </Typography>
                )}
              </CardContent>

              <CardActions sx={{ justifyContent: "flex-end", p: 2 }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(observation)}
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
                  onClick={() => handleDelete(observation)}
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

        {weatherObservations.length === 0 && (
          <Box textAlign="center" py={6}>
            <Typography
              variant="h5"
              sx={{
                color: "#94a3b8",
                fontWeight: 500,
                mb: 2,
              }}
            >
              📭 天候観測記録が登録されていません
            </Typography>
            <Typography
              variant="body1"
              sx={{
                color: "#64748b",
                fontStyle: "italic",
              }}
            >
              新規天候観測を追加してください
            </Typography>
          </Box>
        )}

        {/* フォームダイアログ */}
        <WeatherObservationForm
          open={formOpen}
          onClose={handleFormClose}
          observation={selectedObservation}
        />

        {/* 削除確認ダイアログ */}
        <DeleteWeatherObservationDialog
          open={deleteDialogOpen}
          onClose={handleDeleteDialogClose}
          observation={selectedObservation}
        />
      </Box>
    </Box>
  );
};

export default WeatherObservationsPage;
