import React from 'react';
import { Box, AppBar, Toolbar, Typography, Button, Container } from '@mui/material';
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
      {/* サイドバー */}
      <Sidebar />
      
      {/* メインコンテンツ */}
      <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
        {/* ヘッダー */}
        <AppBar position="static" sx={{ backgroundColor: 'white', color: 'text.primary' }}>
          <Toolbar>
            <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
              TeaFarmOps
            </Typography>
            <Typography variant="body2" sx={{ mr: 2 }}>
              {user?.username} ({user?.role})
            </Typography>
            <Button color="inherit" onClick={handleLogout}>
              ログアウト
            </Button>
          </Toolbar>
        </AppBar>
        
        {/* メインコンテンツエリア */}
        <Container maxWidth="xl" sx={{ flexGrow: 1, py: 3 }}>
          {children}
        </Container>
      </Box>
    </Box>
  );
};

export default Layout; 