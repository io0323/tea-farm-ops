import React from "react";
import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Box,
  Typography,
} from "@mui/material";
import {
  Dashboard as DashboardIcon,
  Agriculture as FieldIcon,
  Assignment as TaskIcon,
  LocalShipping as HarvestIcon,
  WbSunny as WeatherIcon,
} from "@mui/icons-material";
import { useNavigate, useLocation } from "react-router-dom";

const drawerWidth = 240;

const menuItems = [
  { text: "ダッシュボード", icon: <DashboardIcon />, path: "/" },
  { text: "フィールド管理", icon: <FieldIcon />, path: "/fields" },
  { text: "タスク管理", icon: <TaskIcon />, path: "/tasks" },
  { text: "収穫記録", icon: <HarvestIcon />, path: "/harvest-records" },
  { text: "天候観測", icon: <WeatherIcon />, path: "/weather-observations" },
];

const Sidebar: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        "& .MuiDrawer-paper": {
          width: drawerWidth,
          boxSizing: "border-box",
          background: "linear-gradient(180deg, #0f172a 0%, #1e293b 100%)",
          color: "#f1f5f9",
          borderRight: "1px solid #475569",
        },
      }}
    >
      <Box sx={{ p: 3, borderBottom: "1px solid #475569" }}>
        <Typography
          variant="h5"
          sx={{
            fontWeight: 700,
            color: "#4ade80",
            display: "flex",
            alignItems: "center",
            gap: 1,
          }}
        >
          🍃 TeaFarmOps
        </Typography>
        <Typography
          variant="body2"
          sx={{
            color: "#94a3b8",
            mt: 0.5,
            fontStyle: "italic",
          }}
        >
          茶園運営管理システム
        </Typography>
      </Box>

      <List sx={{ pt: 2 }}>
        {menuItems.map((item) => (
          <ListItem key={item.text} disablePadding>
            <ListItemButton
              onClick={() => navigate(item.path)}
              selected={location.pathname === item.path}
              sx={{
                mx: 1,
                mb: 0.5,
                borderRadius: 2,
                "&.Mui-selected": {
                  background:
                    "linear-gradient(135deg, rgba(74, 222, 128, 0.1) 0%, rgba(74, 222, 128, 0.05) 100%)",
                  border: "1px solid rgba(74, 222, 128, 0.3)",
                  "&:hover": {
                    background:
                      "linear-gradient(135deg, rgba(74, 222, 128, 0.15) 0%, rgba(74, 222, 128, 0.1) 100%)",
                  },
                  "& .MuiListItemIcon-root": {
                    color: "#4ade80",
                  },
                  "& .MuiListItemText-primary": {
                    color: "#4ade80",
                    fontWeight: 600,
                  },
                },
                "&:hover": {
                  background: "rgba(255, 255, 255, 0.05)",
                },
              }}
            >
              <ListItemIcon
                sx={{
                  color:
                    location.pathname === item.path ? "#4ade80" : "#94a3b8",
                  minWidth: 40,
                }}
              >
                {item.icon}
              </ListItemIcon>
              <ListItemText
                primary={item.text}
                sx={{
                  "& .MuiListItemText-primary": {
                    color:
                      location.pathname === item.path ? "#4ade80" : "#f1f5f9",
                    fontWeight: location.pathname === item.path ? 600 : 400,
                  },
                }}
              />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Drawer>
  );
};

export default Sidebar;
