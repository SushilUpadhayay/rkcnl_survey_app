import React, { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../features/auth/AuthContext';
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  List,
  Typography,
  Divider,
  IconButton,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Avatar,
  Menu,
  MenuItem,
  Tooltip,
  Button,
} from '@mui/material';
import {
  Menu as MenuIcon,
  ChevronLeft as ChevronLeftIcon,
  Dashboard as DashboardIcon,
  Category as CategoryIcon,
  AssignmentTurnedIn as AssignmentIcon,
  Poll as ResponsesIcon,
  BarChart as ReportsIcon,
  People as UsersIcon,
  AccountCircle as ProfileIcon,
  Brightness4 as DarkModeIcon,
  Brightness7 as LightModeIcon,
  ExitToApp as LogoutIcon,
  Build as BuilderIcon,
  Checklist as SurveysIcon,
} from '@mui/icons-material';

const drawerWidth = 260;

interface DashboardLayoutProps {
  mode: 'light' | 'dark';
  setMode: (mode: 'light' | 'dark') => void;
}

export const DashboardLayout: React.FC<DashboardLayoutProps> = ({ mode, setMode }) => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(true);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    handleMenuClose();
    logout();
    navigate('/login');
  };

  const handleThemeToggle = () => {
    setMode(mode === 'light' ? 'dark' : 'light');
  };

  const menuItems = [
    { text: 'Dashboard', icon: <DashboardIcon />, path: '/' },
    { text: 'Categories', icon: <CategoryIcon />, path: '/categories' },
    { text: 'Surveys', icon: <SurveysIcon />, path: '/surveys' },
    { text: 'Users', icon: <UsersIcon />, path: '/users' },
    { text: 'Assignments', icon: <AssignmentIcon />, path: '/assignments' },
    { text: 'Responses', icon: <ResponsesIcon />, path: '/responses' },
    { text: 'Reports', icon: <ReportsIcon />, path: '/reports' },
  ];

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'background.default' }}>
      <AppBar
        position="fixed"
        sx={{
          zIndex: (theme) => theme.zIndex.drawer + 1,
          transition: (theme) =>
            theme.transitions.create(['width', 'margin'], {
              easing: theme.transitions.easing.sharp,
              duration: theme.transitions.duration.leavingScreen,
            }),
          ...(open && {
            marginLeft: `${drawerWidth}px`,
            width: `calc(100% - ${drawerWidth}px)`,
            transition: (theme) =>
              theme.transitions.create(['width', 'margin'], {
                easing: theme.transitions.easing.sharp,
                duration: theme.transitions.duration.enteringScreen,
              }),
          }),
          boxShadow: 'none',
          borderBottom: '1px solid',
          borderColor: 'divider',
          bgcolor: 'background.paper',
          color: 'text.primary',
        }}
      >
        <Toolbar sx={{ justifyContent: 'space-between' }}>
          <Box sx={{ display: 'flex', alignItems: 'center' }}>
            <IconButton
              color="inherit"
              aria-label="open drawer"
              onClick={() => setOpen(!open)}
              edge="start"
              sx={{ marginRight: 2 }}
            >
              <MenuIcon />
            </IconButton>
            <Typography variant="h5" noWrap component="div" sx={{ fontWeight: 600, color: 'primary.main' }}>
              RKCNL Survey Portal
            </Typography>
          </Box>

          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <IconButton onClick={handleThemeToggle} color="inherit">
              {mode === 'dark' ? <LightModeIcon /> : <DarkModeIcon />}
            </IconButton>

            <Tooltip title="Account settings">
              <IconButton onClick={handleMenuOpen} size="small" sx={{ ml: 2 }}>
                <Avatar
                  sx={{
                    width: 36,
                    height: 36,
                    bgcolor: 'primary.main',
                    fontSize: '1rem',
                    fontWeight: 600,
                  }}
                >
                  {user?.username?.substring(0, 2).toUpperCase()}
                </Avatar>
              </IconButton>
            </Tooltip>

            <Menu
              anchorEl={anchorEl}
              open={Boolean(anchorEl)}
              onClose={handleMenuClose}
              transformOrigin={{ horizontal: 'right', vertical: 'top' }}
              anchorOrigin={{ horizontal: 'right', vertical: 'bottom' }}
              slotProps={{
                paper: {
                  elevation: 4,
                  sx: {
                    overflow: 'visible',
                    filter: 'drop-shadow(0px 2px 8px rgba(0,0,0,0.15))',
                    mt: 1.5,
                    minWidth: 200,
                    borderRadius: 2,
                    '& .MuiAvatar-root': {
                      width: 32,
                      height: 32,
                      ml: -0.5,
                      mr: 1,
                    },
                  },
                },
              }}
            >
              <Box sx={{ px: 2, py: 1.5 }}>
                <Typography variant="subtitle2" sx={{ fontWeight: 600 }}>
                  {user?.username}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {user?.email}
                </Typography>
                <Typography variant="caption" sx={{ mt: 0.5, display: 'inline-block', bgcolor: 'primary.light', color: 'primary.contrastText', px: 1, py: 0.2, borderRadius: 1, fontWeight: 600 }}>
                  {user?.role}
                </Typography>
              </Box>
              <Divider />
              <MenuItem onClick={() => { handleMenuClose(); navigate('/profile'); }}>
                <ListItemIcon>
                  <ProfileIcon fontSize="small" />
                </ListItemIcon>
                Profile
              </MenuItem>
              <MenuItem onClick={handleLogout}>
                <ListItemIcon>
                  <LogoutIcon fontSize="small" color="error" />
                </ListItemIcon>
                <Typography color="error">Logout</Typography>
              </MenuItem>
            </Menu>
          </Box>
        </Toolbar>
      </AppBar>

      <Drawer
        variant="permanent"
        open={open}
        sx={{
          width: open ? drawerWidth : 0,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: drawerWidth,
            boxSizing: 'border-box',
            borderRight: '1px solid',
            borderColor: 'divider',
            bgcolor: 'background.paper',
            transition: (theme) =>
              theme.transitions.create('width', {
                easing: theme.transitions.easing.sharp,
                duration: theme.transitions.duration.enteringScreen,
              }),
            ...(!open && {
              width: 0,
              overflowX: 'hidden',
              transition: (theme) =>
                theme.transitions.create('width', {
                  easing: theme.transitions.easing.sharp,
                  duration: theme.transitions.duration.leavingScreen,
                }),
            }),
          },
        }}
      >
        <Toolbar sx={{ display: 'flex', alignItems: 'center', justifyContent: 'flex-end', px: [1] }}>
          <IconButton onClick={() => setOpen(false)}>
            <ChevronLeftIcon />
          </IconButton>
        </Toolbar>
        <Divider />
        
        <Box sx={{ p: 2 }}>
          <Button
            variant="contained"
            color="primary"
            fullWidth
            startIcon={<BuilderIcon />}
            onClick={() => navigate('/surveys/new')}
            sx={{ py: 1.2, borderRadius: 2, fontWeight: 600 }}
          >
            Question Builder
          </Button>
        </Box>
        
        <Divider />
        <List sx={{ px: 1.5, py: 1 }}>
          {menuItems.map((item) => {
            const isSelected = location.pathname === item.path || 
              (item.path !== '/' && location.pathname.startsWith(item.path));
            return (
              <ListItem key={item.text} disablePadding sx={{ display: 'block', mb: 0.5 }}>
                <ListItemButton
                  onClick={() => navigate(item.path)}
                  selected={isSelected}
                  sx={{
                    minHeight: 48,
                    px: 2.5,
                    borderRadius: 2,
                    color: isSelected ? 'primary.main' : 'text.secondary',
                    bgcolor: isSelected ? 'primary.subtle' : 'transparent',
                    '&.Mui-selected': {
                      bgcolor: mode === 'dark' ? 'rgba(0, 128, 0, 0.15)' : 'rgba(0, 128, 0, 0.08)',
                      '&:hover': {
                        bgcolor: mode === 'dark' ? 'rgba(0, 128, 0, 0.25)' : 'rgba(0, 128, 0, 0.12)',
                      },
                    },
                    '&:hover': {
                      bgcolor: mode === 'dark' ? 'rgba(255, 255, 255, 0.05)' : 'rgba(0, 0, 0, 0.02)',
                    },
                  }}
                >
                  <ListItemIcon
                    sx={{
                      minWidth: 0,
                      mr: 2,
                      justifyContent: 'center',
                      color: isSelected ? 'primary.main' : 'text.secondary',
                    }}
                  >
                    {item.icon}
                  </ListItemIcon>
                  <ListItemText
                    primary={
                      <Typography sx={{ fontWeight: isSelected ? 600 : 500, fontSize: '0.925rem' }}>
                        {item.text}
                      </Typography>
                    }
                  />
                </ListItemButton>
              </ListItem>
            );
          })}
        </List>
      </Drawer>

      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 4,
          width: open ? `calc(100% - ${drawerWidth}px)` : '100%',
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
          transition: (theme) =>
            theme.transitions.create(['width', 'margin'], {
              easing: theme.transitions.easing.sharp,
              duration: theme.transitions.duration.leavingScreen,
            }),
        }}
      >
        <Toolbar />
        <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
};
