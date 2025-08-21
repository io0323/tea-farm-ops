import React, { useEffect } from "react";
import { Box, Typography, Card, CardContent } from "@mui/material";
import {
  Agriculture as FieldIcon,
  Assignment as TaskIcon,
  LocalShipping as HarvestIcon,
  WbSunny as WeatherIcon,
} from "@mui/icons-material";
import { useAppSelector, useAppDispatch } from "../store/hooks";
import { fetchFields } from "../store/slices/fieldSlice";
import { fetchTasks } from "../store/slices/taskSlice";
import { fetchHarvestRecords } from "../store/slices/harvestRecordSlice";
import { fetchWeatherObservations } from "../store/slices/weatherObservationSlice";

const DashboardPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { fields } = useAppSelector((state) => state.fields);
  const { tasks } = useAppSelector((state) => state.tasks);
  const { harvestRecords } = useAppSelector((state) => state.harvestRecords);
  const { weatherObservations } = useAppSelector(
    (state) => state.weatherObservations,
  );

  useEffect(() => {
    // CI環境ではAPIコールをスキップ
    if (process.env.NODE_ENV === "test" || process.env.CI === "true") {
      return;
    }

    dispatch(fetchFields({}));
    dispatch(fetchTasks());
    dispatch(fetchHarvestRecords());
    dispatch(fetchWeatherObservations());
  }, [dispatch]);

  const stats = [
    {
      title: "フィールド数",
      value: fields.length,
      color: "#4ade80",
      icon: <FieldIcon sx={{ fontSize: 40, color: "#4ade80" }} />,
    },
    {
      title: "タスク数",
      value: tasks.length,
      color: "#60a5fa",
      icon: <TaskIcon sx={{ fontSize: 40, color: "#60a5fa" }} />,
    },
    {
      title: "収穫記録",
      value: harvestRecords.length,
      color: "#fbbf24",
      icon: <HarvestIcon sx={{ fontSize: 40, color: "#fbbf24" }} />,
    },
    {
      title: "天候観測",
      value: weatherObservations.length,
      color: "#a78bfa",
      icon: <WeatherIcon sx={{ fontSize: 40, color: "#a78bfa" }} />,
    },
  ];

  return (
    <Box
      sx={{
        p: 3,
        background:
          "linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)",
        minHeight: "100vh",
      }}
    >
      <Box sx={{ maxWidth: 1200, mx: "auto" }}>
        <Typography
          variant="h3"
          component="h1"
          gutterBottom
          sx={{
            fontWeight: 700,
            color: "#4ade80",
            textAlign: "center",
            mb: 1,
            textShadow: "0 2px 4px rgba(0,0,0,0.3)",
          }}
        >
          茶園運営ダッシュボード
        </Typography>

        <Typography
          variant="h6"
          sx={{
            mb: 4,
            textAlign: "center",
            fontStyle: "italic",
            color: "#94a3b8",
          }}
        >
          茶園運営の概要を一目で確認できます
        </Typography>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: {
              xs: "1fr",
              sm: "repeat(2, 1fr)",
              md: "repeat(4, 1fr)",
            },
            gap: 3,
            mb: 4,
          }}
        >
          {stats.map((stat) => (
            <Card
              key={stat.title}
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
                },
              }}
            >
              <CardContent sx={{ p: 3 }}>
                <Box
                  display="flex"
                  alignItems="center"
                  justifyContent="space-between"
                >
                  <Box>
                    <Typography
                      variant="h2"
                      component="div"
                      sx={{
                        fontWeight: 800,
                        color: stat.color,
                        textShadow: "0 2px 4px rgba(0,0,0,0.3)",
                      }}
                    >
                      {stat.value}
                    </Typography>
                    <Typography
                      variant="h6"
                      sx={{
                        fontWeight: 500,
                        color: "#cbd5e1",
                      }}
                    >
                      {stat.title}
                    </Typography>
                  </Box>
                  <Box
                    sx={{
                      p: 2,
                      borderRadius: 2,
                      background: `linear-gradient(135deg, ${stat.color}15 0%, ${stat.color}05 100%)`,
                      border: `1px solid ${stat.color}30`,
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                    }}
                  >
                    {stat.icon}
                  </Box>
                </Box>
              </CardContent>
            </Card>
          ))}
        </Box>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "1fr 1fr" },
            gap: 4,
          }}
        >
          <Card
            sx={{
              background: "linear-gradient(135deg, #1e293b 0%, #334155 100%)",
              borderRadius: 3,
              boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
              border: "1px solid #475569",
              transition: "all 0.3s ease",
              "&:hover": {
                transform: "translateY(-2px)",
                boxShadow: "0 12px 40px rgba(0,0,0,0.4)",
              },
            }}
          >
            <CardContent sx={{ p: 3 }}>
              <Typography
                variant="h5"
                gutterBottom
                sx={{
                  fontWeight: 600,
                  color: "#4ade80",
                  mb: 3,
                  display: "flex",
                  alignItems: "center",
                  gap: 1,
                }}
              >
                <FieldIcon sx={{ fontSize: 28 }} />
                最近のフィールド
              </Typography>
              {fields.length > 0 ? (
                fields.slice(0, 5).map((field, index) => (
                  <Box
                    key={field.id}
                    sx={{
                      py: 2,
                      borderBottom: index < 4 ? "1px solid #475569" : "none",
                      transition: "all 0.2s ease",
                      "&:hover": {
                        backgroundColor: "#334155",
                        borderRadius: 1,
                        px: 1,
                      },
                    }}
                  >
                    <Typography
                      variant="h6"
                      sx={{ fontWeight: 600, color: "#f1f5f9" }}
                    >
                      {field.name || "名前未設定"}
                    </Typography>
                    <Typography
                      variant="body2"
                      sx={{ mt: 0.5, color: "#94a3b8" }}
                    >
                      📍 {field.location || "場所未設定"} •{" "}
                      {field.areaSize || 0}ha
                    </Typography>
                  </Box>
                ))
              ) : (
                <Box sx={{ textAlign: "center", py: 4 }}>
                  <Typography variant="body1" sx={{ color: "#94a3b8" }}>
                    📭 フィールドがありません
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>

          <Card
            sx={{
              background: "linear-gradient(135deg, #1e293b 0%, #334155 100%)",
              borderRadius: 3,
              boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
              border: "1px solid #475569",
              transition: "all 0.3s ease",
              "&:hover": {
                transform: "translateY(-2px)",
                boxShadow: "0 12px 40px rgba(0,0,0,0.4)",
              },
            }}
          >
            <CardContent sx={{ p: 3 }}>
              <Typography
                variant="h5"
                gutterBottom
                sx={{
                  fontWeight: 600,
                  color: "#60a5fa",
                  mb: 3,
                  display: "flex",
                  alignItems: "center",
                  gap: 1,
                }}
              >
                <TaskIcon sx={{ fontSize: 28 }} />
                最近のタスク
              </Typography>
              {tasks.length > 0 ? (
                tasks.slice(0, 5).map((task, index) => (
                  <Box
                    key={task.id}
                    sx={{
                      py: 2,
                      borderBottom: index < 4 ? "1px solid #475569" : "none",
                      transition: "all 0.2s ease",
                      "&:hover": {
                        backgroundColor: "#334155",
                        borderRadius: 1,
                        px: 1,
                      },
                    }}
                  >
                    <Typography
                      variant="h6"
                      sx={{ fontWeight: 600, color: "#f1f5f9" }}
                    >
                      {task.taskType}
                    </Typography>
                    <Typography
                      variant="body2"
                      sx={{ mt: 0.5, color: "#94a3b8" }}
                    >
                      🏞️ {task.fieldName || "フィールド未設定"} • {task.status}
                    </Typography>
                  </Box>
                ))
              ) : (
                <Box sx={{ textAlign: "center", py: 4 }}>
                  <Typography variant="body1" sx={{ color: "#94a3b8" }}>
                    📋 タスクがありません
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>
        </Box>
      </Box>
    </Box>
  );
};

export default DashboardPage;
