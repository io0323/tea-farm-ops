import React, { useEffect, useState } from 'react';
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Chip,
  CircularProgress,
  IconButton,
  CardActions,
} from '@mui/material';
import { 
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';
import { useAppSelector, useAppDispatch } from '../store/hooks';
import { fetchTasks } from '../store/slices/taskSlice';
import { Task } from '../types';
import TaskForm from '../components/tasks/TaskForm';
import DeleteTaskDialog from '../components/tasks/DeleteTaskDialog';

const TasksPage: React.FC = () => {
  const dispatch = useAppDispatch();
  const { tasks, loading } = useAppSelector((state) => state.tasks);
  
  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);

  useEffect(() => {
    dispatch(fetchTasks());
  }, [dispatch]);

  const handleCreate = () => {
    setSelectedTask(null);
    setFormOpen(true);
  };

  const handleEdit = (task: Task) => {
    setSelectedTask(task);
    setFormOpen(true);
  };

  const handleDelete = (task: Task) => {
    setSelectedTask(task);
    setDeleteDialogOpen(true);
  };

  const handleFormClose = () => {
    setFormOpen(false);
    setSelectedTask(null);
  };

  const handleDeleteDialogClose = () => {
    setDeleteDialogOpen(false);
    setSelectedTask(null);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'PENDING':
        return 'warning';
      case 'IN_PROGRESS':
        return 'info';
      case 'COMPLETED':
        return 'success';
      case 'CANCELLED':
        return 'error';
      default:
        return 'default';
    }
  };

  if (loading) {
    return (
      <Box 
        display="flex" 
        justifyContent="center" 
        alignItems="center" 
        minHeight="400px"
        sx={{ 
          background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)',
          minHeight: '100vh'
        }}
      >
        <CircularProgress sx={{ color: '#60a5fa' }} />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3, background: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%)', minHeight: '100vh' }}>
      <Box sx={{ maxWidth: 1400, mx: 'auto' }}>
        <Box display="flex" justifyContent="space-between" alignItems="center" sx={{ mb: 4 }}>
          <Typography 
            variant="h3" 
            component="h1"
            sx={{ 
              fontWeight: 700, 
              color: '#60a5fa',
              textShadow: '0 2px 4px rgba(0,0,0,0.3)'
            }}
          >
            📋 タスク管理
          </Typography>
          <Button
            variant="contained"
            startIcon={<AddIcon />}
            size="large"
            onClick={handleCreate}
            sx={{
              background: 'linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%)',
              boxShadow: '0 4px 15px rgba(96, 165, 250, 0.3)',
              '&:hover': {
                background: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
                boxShadow: '0 6px 20px rgba(96, 165, 250, 0.4)',
              }
            }}
          >
            新規タスク
          </Button>
        </Box>

        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)', md: 'repeat(3, 1fr)' }, gap: 3 }}>
          {tasks.map((task) => (
            <Card 
              key={task.id} 
              sx={{ 
                height: '100%',
                background: 'linear-gradient(135deg, #1e293b 0%, #334155 100%)',
                borderRadius: 3,
                boxShadow: '0 8px 32px rgba(0,0,0,0.3)',
                border: '1px solid #475569',
                transition: 'all 0.3s ease',
                '&:hover': {
                  transform: 'translateY(-4px)',
                  boxShadow: '0 12px 40px rgba(0,0,0,0.4)',
                  border: '1px solid #64748b',
                }
              }}
            >
              <CardContent sx={{ p: 3 }}>
                <Typography 
                  variant="h6" 
                  gutterBottom
                  sx={{ 
                    fontWeight: 600,
                    color: '#f1f5f9'
                  }}
                >
                  {task.taskType}
                </Typography>
                <Typography 
                  variant="body2" 
                  sx={{ 
                    mb: 2,
                    color: '#94a3b8'
                  }}
                >
                  🏞️ {task.fieldName}
                </Typography>
                
                <Box display="flex" gap={1} sx={{ mb: 2 }}>
                  <Chip
                    label={task.status}
                    size="small"
                    sx={{
                      backgroundColor: task.status === 'COMPLETED' ? '#4ade80' : 
                                   task.status === 'IN_PROGRESS' ? '#60a5fa' :
                                   task.status === 'PENDING' ? '#fbbf24' : '#f87171',
                      color: '#1e293b',
                      fontWeight: 600,
                    }}
                  />
                  <Chip
                    label={task.assignedWorker}
                    size="small"
                    variant="outlined"
                    sx={{
                      borderColor: '#60a5fa',
                      color: '#60a5fa',
                    }}
                  />
                </Box>

                <Typography 
                  variant="body2" 
                  sx={{ 
                    color: '#cbd5e1',
                    mb: 1
                  }}
                >
                  📅 {task.startDate} - {task.endDate}
                </Typography>

                {task.notes && (
                  <Typography 
                    variant="body2" 
                    sx={{ 
                      color: '#cbd5e1',
                      fontStyle: 'italic'
                    }}
                  >
                    {task.notes}
                  </Typography>
                )}
              </CardContent>
              
              <CardActions sx={{ justifyContent: 'flex-end', p: 2 }}>
                <IconButton
                  size="small"
                  onClick={() => handleEdit(task)}
                  sx={{
                    color: '#60a5fa',
                    '&:hover': {
                      backgroundColor: 'rgba(96, 165, 250, 0.1)',
                    }
                  }}
                >
                  <EditIcon />
                </IconButton>
                <IconButton
                  size="small"
                  onClick={() => handleDelete(task)}
                  sx={{
                    color: '#f87171',
                    '&:hover': {
                      backgroundColor: 'rgba(248, 113, 113, 0.1)',
                    }
                  }}
                >
                  <DeleteIcon />
                </IconButton>
              </CardActions>
            </Card>
          ))}
        </Box>

        {tasks.length === 0 && (
          <Box textAlign="center" py={6}>
            <Typography 
              variant="h5" 
              sx={{ 
                color: '#94a3b8',
                fontWeight: 500,
                mb: 2
              }}
            >
              📭 タスクが登録されていません
            </Typography>
            <Typography 
              variant="body1" 
              sx={{ 
                color: '#64748b',
                fontStyle: 'italic'
              }}
            >
              新規タスクを追加してください
            </Typography>
          </Box>
        )}

        {/* フォームダイアログ */}
        <TaskForm
          open={formOpen}
          onClose={handleFormClose}
          task={selectedTask}
        />

        {/* 削除確認ダイアログ */}
        <DeleteTaskDialog
          open={deleteDialogOpen}
          onClose={handleDeleteDialogClose}
          task={selectedTask}
        />
      </Box>
    </Box>
  );
};

export default TasksPage; 