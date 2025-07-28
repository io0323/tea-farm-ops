import React, { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { getCurrentUser } from '../store/slices/authSlice';
import Layout from '../components/Layout/Layout';
import LoginPage from '../pages/LoginPage';
import DashboardPage from '../pages/DashboardPage';
import FieldsPage from '../pages/FieldsPage';
import TasksPage from '../pages/TasksPage';
import HarvestRecordsPage from '../pages/HarvestRecordsPage';
import WeatherObservationsPage from '../pages/WeatherObservationsPage';
import LoadingSpinner from '../components/common/LoadingSpinner';

const AppRoutes: React.FC = () => {
  const dispatch = useAppDispatch();
  const { isAuthenticated, loading } = useAppSelector((state) => state.auth);

  useEffect(() => {
    // トークンが存在する場合、ユーザー情報を取得
    if (localStorage.getItem('authToken')) {
      dispatch(getCurrentUser());
    }
  }, [dispatch]);

  // ローディング中
  if (loading) {
    return <LoadingSpinner />;
  }

  // 未認証の場合、ログインページにリダイレクト
  if (!isAuthenticated) {
    return (
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    );
  }

  // 認証済みの場合、メインアプリケーション
  return (
    <Layout>
      <Routes>
        <Route path="/" element={<DashboardPage />} />
        <Route path="/fields" element={<FieldsPage />} />
        <Route path="/tasks" element={<TasksPage />} />
        <Route path="/harvest-records" element={<HarvestRecordsPage />} />
        <Route path="/weather-observations" element={<WeatherObservationsPage />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Layout>
  );
};

export default AppRoutes; 