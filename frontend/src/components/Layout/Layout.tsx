import React from 'react';
import { Box, AppBar, Toolbar, Typography, Button } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { useAppSelector, useAppDispatch } from '../../store/hooks';
import { logout } from '../../store/slices/authSlice';
import Sidebar from './Sidebar';

interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const navigate = useNavigate();
  const dispatch = useAppDispatch();
  const { user } = useAppSelector((state) => state.auth);

  const handleLogout = () => {
    dispatch(logout());
    navigate('/login');
  };

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>
      <Sidebar />
      
      <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
        <AppBar 
          position="static" 
          sx={{ 
            background: 'linear-gradient(135deg, #1e293b 0%, #334155 100%)',
            color: '#f1f5f9',
            borderBottom: '1px solid #475569',
            boxShadow: '0 4px 20px rgba(0,0,0,0.3)'
          }}
        >
          <Toolbar>
            <Typography 
              variant="h6" 
              component="div" 
              sx={{ 
                flexGrow: 1,
                fontWeight: 600,
                color: '#4ade80'
              }}
            >
              🍃 TeaFarmOps
            </Typography>
            <Typography 
              variant="body2" 
              sx={{ 
                mr: 2,
                color: '#94a3b8'
              }}
            >
              👤 {user?.username} ({user?.role})
            </Typography>
            <Button 
              onClick={handleLogout}
              sx={{
                color: '#f87171',
                border: '1px solid #f87171',
                '&:hover': {
                  backgroundColor: 'rgba(248, 113, 113, 0.1)',
                  borderColor: '#ef4444',
                }
              }}
            >
              ログアウト
            </Button>
          </Toolbar>
        </AppBar>
        
        <Box sx={{ flexGrow: 1 }}>
          {children}
        </Box>
      </Box>
    </Box>
  );
};

export default Layout; 