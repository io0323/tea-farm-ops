import React from "react";
import { Box, CircularProgress, Typography } from "@mui/material";

interface LoadingSpinnerProps {
  message?: string;
}

const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({
  message = "読み込み中...",
}) => {
  return (
    <Box
      display="flex"
      flexDirection="column"
      alignItems="center"
      justifyContent="center"
      minHeight="100vh"
      gap={2}
    >
      <CircularProgress size={60} />
      <Typography variant="h6" color="text.secondary">
        {message}
      </Typography>
    </Box>
  );
};

export default LoadingSpinner;
