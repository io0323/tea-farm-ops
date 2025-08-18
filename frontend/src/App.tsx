import React from "react";
import { Provider } from "react-redux";
import { BrowserRouter as Router } from "react-router-dom";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import { store } from "./store";
import AppRoutes from "./routes/AppRoutes";

const theme = createTheme({
  palette: {
    mode: "dark",
    primary: {
      main: "#4ade80",
    },
    secondary: {
      main: "#60a5fa",
    },
    background: {
      default: "#1a1a2e",
      paper: "#1e293b",
    },
    text: {
      primary: "#f1f5f9",
      secondary: "#94a3b8",
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: "none",
          fontWeight: 600,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 12,
          boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
          background: "linear-gradient(135deg, #1e293b 0%, #334155 100%)",
          border: "1px solid #475569",
        },
      },
    },
    MuiCircularProgress: {
      styleOverrides: {
        root: {
          color: "#4ade80",
        },
      },
    },
  },
});

function App() {
  return (
    <Provider store={store}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
          <AppRoutes />
        </Router>
      </ThemeProvider>
    </Provider>
  );
}

export default App;
