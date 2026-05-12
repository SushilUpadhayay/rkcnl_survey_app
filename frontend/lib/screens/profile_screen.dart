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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProfileHeader(appState),
              const SizedBox(height: 32),
              _buildInfoList(appState),
              const SizedBox(height: 32),
              _buildActionButtons(context, appState),
              const SizedBox(height: 32),
              const Text('V1.0.0 Build 2026.03.02', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppState appState) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.green,
              child: Text(appState.userInitials, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(appState.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(20)),
          child: const Text('Field Surveyor – RKCNL', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildInfoList(AppState appState) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildInfoTile(Icons.alternate_email, 'Email Address', '${appState.userName.toLowerCase().replaceAll(' ', '.')}@rkcnl.gov.np'),
          const Divider(),
          _buildInfoTile(Icons.phone_outlined, 'Phone Number', '+977 9812345678'),
          const Divider(),
          _buildInfoTile(Icons.location_on_outlined, 'Assigned Region', appState.userRegion),
          const Divider(),
          _buildInfoTile(Icons.badge_outlined, 'Employee ID', 'EMP-2025-089'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppState appState) {
    return Column(
      children: [
        ListTile(
          onTap: () {},
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.help_center_outlined, color: AppColors.blue)),
          title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          trailing: const Icon(Icons.chevron_right, size: 20),
        ),
        const Divider(),
        ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout?'),
                content: const Text('Are you sure you want to log out? Offline data will remain saved.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(onPressed: () {
                    appState.logout();
                    Navigator.pop(context); // Close dialog
                    context.go('/login');
                  }, child: const Text('Logout', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold))),
                ],
              ),
            );
          },
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.logout, color: AppColors.red)),
          title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.red)),
        ),
      ],
    );
  }
}
