import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  LinearProgress,
} from '@mui/material';
import { SvgIconComponent } from '@mui/icons-material';

interface StatisticsCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: React.ReactElement<SvgIconComponent>;
  color: string;
  progress?: number;
  trend?: {
    value: number;
    isPositive: boolean;
  };
}

const StatisticsCard: React.FC<StatisticsCardProps> = ({
  title,
  value,
  subtitle,
  icon,
  color,
  progress,
  trend,
}) => {
  return (
    <Card sx={{ height: '100%', position: 'relative', overflow: 'visible' }}>
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start">
          <Box flex={1}>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              {title}
            </Typography>
            <Typography variant="h4" component="div" sx={{ fontWeight: 'bold', mb: 1 }}>
              {value}
            </Typography>
            {subtitle && (
              <Typography variant="body2" color="text.secondary">
                {subtitle}
              </Typography>
            )}
            {trend && (
              <Box display="flex" alignItems="center" gap={0.5} sx={{ mt: 1 }}>
                <Typography
                  variant="body2"
                  color={trend.isPositive ? 'success.main' : 'error.main'}
                  sx={{ fontWeight: 'bold' }}
                >
                  {trend.isPositive ? '+' : ''}{trend.value}%
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  前月比
                </Typography>
              </Box>
            )}
          </Box>
          <Box
            sx={{
              backgroundColor: color,
              borderRadius: '50%',
              width: 48,
              height: 48,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
            }}
          >
            {icon}
          </Box>
        </Box>
        
        {progress !== undefined && (
          <Box sx={{ mt: 2 }}>
            <Box display="flex" justifyContent="space-between" alignItems="center" sx={{ mb: 1 }}>
              <Typography variant="body2" color="text.secondary">
                進捗
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {progress}%
              </Typography>
            </Box>
            <LinearProgress
              variant="determinate"
              value={progress}
              sx={{
                height: 6,
                borderRadius: 3,
                backgroundColor: 'grey.200',
                '& .MuiLinearProgress-bar': {
                  backgroundColor: color,
                  borderRadius: 3,
                },
              }}
            />
          </Box>
        )}
      </CardContent>
    </Card>
  );
};

export default StatisticsCard; 