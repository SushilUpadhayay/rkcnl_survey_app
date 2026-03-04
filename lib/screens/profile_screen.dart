import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tc = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings')),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(appState, tc),
              const SizedBox(height: 32),
              _buildInfoList(appState, tc),
              const SizedBox(height: 32),
              _buildActionButtons(context, appState, tc),
              const SizedBox(height: 32),
              Text('V1.0.0 Build 2026.03.02',
                  style: TextStyle(
                      color: tc.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppState appState, AppThemeColors tc) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.green,
              child: Text(appState.userInitials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration:
                    BoxDecoration(color: tc.surface, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: AppColors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(appState.userName,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
              color: tc.greenLight, borderRadius: BorderRadius.circular(20)),
          child: const Text('Field Surveyor – RKCNL',
              style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildInfoList(AppState appState, AppThemeColors tc) {
    return Container(
      decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.border)),
      child: Column(
        children: [
          _buildInfoTile(
              Icons.alternate_email,
              'Email Address',
              '${appState.userName.toLowerCase().replaceAll(' ', '.')}@rkcnl.gov.np',
              tc),
          Divider(color: tc.border),
          _buildInfoTile(
              Icons.phone_outlined, 'Phone Number', '+977 9812345678', tc),
          Divider(color: tc.border),
          _buildInfoTile(Icons.location_on_outlined, 'Assigned Region',
              appState.userRegion, tc),
          Divider(color: tc.border),
          _buildInfoTile(
              Icons.badge_outlined, 'Employee ID', 'EMP-2025-089', tc),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String val, AppThemeColors tc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: tc.textMuted, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: tc.textMuted,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(val,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: tc.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AppState appState, AppThemeColors tc) {
    return Column(
      children: [
        ListTile(
          onTap: () {},
          leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: tc.blueLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.help_center_outlined,
                  color: AppColors.blue)),
          title: Text('Help & Support',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: tc.textPrimary)),
          trailing: Icon(Icons.chevron_right, size: 20, color: tc.textMuted),
        ),
        Divider(color: tc.border),
        ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout?'),
                content: const Text(
                    'Are you sure you want to log out? Offline data will remain saved.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        appState.logout();
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      child: const Text('Logout',
                          style: TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            );
          },
          leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: tc.redLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.logout, color: AppColors.red)),
          title: Text('Logout',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.red)),
        ),
      ],
    );
  }
}
