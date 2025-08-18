import React from "react";
import {
  Card,
  CardContent,
  Typography,
  Chip,
  IconButton,
  CardActions,
  Box,
} from "@mui/material";
import { Edit as EditIcon, Delete as DeleteIcon } from "@mui/icons-material";
import { Field } from "../../types";

interface FieldCardProps {
  field: Field;
  onEdit: (field: Field) => void;
  onDelete: (field: Field) => void;
}

const FieldCard: React.FC<FieldCardProps> = React.memo(
  ({ field, onEdit, onDelete }) => {
    return (
      <Card sx={{ height: "100%" }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            {field.name}
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            {field.location}
          </Typography>

          <Box display="flex" gap={1} sx={{ mb: 2 }}>
            <Chip label={`${field.areaSize}ha`} size="small" color="primary" />
            {field.soilType && (
              <Chip label={field.soilType} size="small" variant="outlined" />
            )}
          </Box>

          {field.notes && (
            <Typography variant="body2" color="text.secondary">
              {field.notes}
            </Typography>
          )}
        </CardContent>

        <CardActions sx={{ justifyContent: "flex-end" }}>
          <IconButton
            size="small"
            onClick={() => onEdit(field)}
            color="primary"
          >
            <EditIcon />
          </IconButton>
          <IconButton
            size="small"
            onClick={() => onDelete(field)}
            color="error"
          >
            <DeleteIcon />
          </IconButton>
        </CardActions>
      </Card>
    );
  },
);

FieldCard.displayName = "FieldCard";

export default FieldCard;
