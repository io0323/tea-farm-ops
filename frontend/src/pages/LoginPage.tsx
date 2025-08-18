import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { login } from '../store/slices/authSlice';

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const dispatch = useAppDispatch();
  const { loading, error, isAuthenticated } = useAppSelector((state) => state.auth);

  const [formData, setFormData] = useState({
    username: '',
    password: '',
  });

  // ログイン成功時にダッシュボードにリダイレクト
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/dashboard');
    }
  }, [isAuthenticated, navigate]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    dispatch(login(formData));
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
        position: 'relative',
        overflow: 'hidden',
        '&::before': {
          content: '""',
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'url("data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23ffffff" fill-opacity="0.03"%3E%3Ccircle cx="30" cy="30" r="2"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
          zIndex: 0,
        }
      }}
    >
      <Card 
        sx={{ 
          width: '100%', 
          maxWidth: 450,
          background: 'rgba(30, 41, 59, 0.95)',
          backdropFilter: 'blur(10px)',
          borderRadius: 4,
          boxShadow: '0 20px 60px rgba(0,0,0,0.4)',
          border: '1px solid rgba(71, 85, 105, 0.3)',
          position: 'relative',
          zIndex: 1,
          transition: 'all 0.3s ease',
          '&:hover': {
            transform: 'translateY(-5px)',
            boxShadow: '0 25px 80px rgba(0,0,0,0.5)',
          }
        }}
      >
        <CardContent sx={{ p: 5 }}>
          <Box sx={{ textAlign: 'center', mb: 4 }}>
            <Typography 
              variant="h3" 
              component="h1" 
              sx={{ 
                fontWeight: 800,
                background: 'linear-gradient(135deg, #4ade80 0%, #22c55e 100%)',
                backgroundClip: 'text',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                mb: 2,
                textShadow: '0 2px 4px rgba(0,0,0,0.3)'
              }}
            >
              🍃 TeaFarmOps
            </Typography>
            
            <Typography 
              variant="h6" 
              sx={{ 
                fontWeight: 400,
                fontStyle: 'italic',
                opacity: 0.8,
                color: '#94a3b8'
              }}
            >
              茶園運営管理システム
            </Typography>
          </Box>

          {error && (
            <Alert 
              severity="error" 
              sx={{ 
                mb: 3,
                borderRadius: 2,
                '& .MuiAlert-icon': {
                  fontSize: 24
                }
              }}
            >
              {error}
            </Alert>
          )}

          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              fullWidth
              label="ユーザー名"
              name="username"
              value={formData.username}
              onChange={handleChange}
              margin="normal"
              required
              autoFocus
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: 2,
                  backgroundColor: 'rgba(51, 65, 85, 0.5)',
                  '&:hover fieldset': {
                    borderColor: '#4ade80',
                  },
                  '&.Mui-focused fieldset': {
                    borderColor: '#4ade80',
                  },
                },
                '& .MuiInputLabel-root': {
                  color: '#94a3b8',
                  '&.Mui-focused': {
                    color: '#4ade80',
                  },
                },
                '& .MuiInputBase-input': {
                  color: '#f1f5f9',
                },
              }}
            />
            
            <TextField
              fullWidth
              label="パスワード"
              name="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              margin="normal"
              required
              sx={{
                '& .MuiOutlinedInput-root': {
                  borderRadius: 2,
                  backgroundColor: 'rgba(51, 65, 85, 0.5)',
                  '&:hover fieldset': {
                    borderColor: '#4ade80',
                  },
                  '&.Mui-focused fieldset': {
                    borderColor: '#4ade80',
                  },
                },
                '& .MuiInputLabel-root': {
                  color: '#94a3b8',
                  '&.Mui-focused': {
                    color: '#4ade80',
                  },
                },
                '& .MuiInputBase-input': {
                  color: '#f1f5f9',
                },
              }}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              size="large"
              disabled={loading}
              sx={{ 
                mt: 4, 
                mb: 3,
                py: 1.5,
                background: 'linear-gradient(135deg, #4ade80 0%, #22c55e 100%)',
                borderRadius: 2,
                fontWeight: 600,
                fontSize: '1.1rem',
                textTransform: 'none',
                boxShadow: '0 8px 25px rgba(74, 222, 128, 0.3)',
                transition: 'all 0.3s ease',
                '&:hover': {
                  background: 'linear-gradient(135deg, #22c55e 0%, #16a34a 100%)',
                  transform: 'translateY(-2px)',
                  boxShadow: '0 12px 35px rgba(74, 222, 128, 0.4)',
                },
                '&:disabled': {
                  background: 'linear-gradient(135deg, #64748b 0%, #475569 100%)',
                  transform: 'none',
                  boxShadow: 'none',
                }
              }}
            >
              {loading ? '🔄 ログイン中...' : '🚀 ログイン'}
            </Button>
          </Box>

          <Box sx={{ 
            mt: 4, 
            p: 3, 
            background: 'linear-gradient(135deg, #334155 0%, #475569 100%)',
            borderRadius: 3,
            border: '1px solid rgba(71, 85, 105, 0.3)',
            textAlign: 'center'
          }}>
            <Typography 
              variant="h6" 
              sx={{ 
                fontWeight: 600,
                mb: 2,
                color: '#4ade80'
              }}
            >
              🎯 デモアカウント
            </Typography>
            <Typography 
              variant="body2" 
              sx={{ 
                lineHeight: 1.8,
                opacity: 0.8,
                color: '#cbd5e1'
              }}
            >
              <strong>管理者:</strong> admin / admin123<br />
              <strong>作業員:</strong> user / user123
            </Typography>
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
};

export default LoginPage; 