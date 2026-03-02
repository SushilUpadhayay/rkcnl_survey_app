import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final notes = appState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => appState.markAllRead(),
            child: const Text('Mark all read', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: notes.isEmpty 
          ? _buildEmptyState() 
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notes[index];
                return _buildNotificationCard(context, n, appState);
              },
            ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, dynamic n, AppState appState) {
    final color = n.colorType == 'green' ? AppColors.green : n.colorType == 'orange' ? AppColors.orange : AppColors.blue;
    final icon = _getIcon(n.icon);

    return InkWell(
      onTap: () => appState.markRead(n.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.read ? AppColors.surface : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: n.read ? AppColors.border : color.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: n.read ? AppColors.textPrimary : color)),
                      Text(n.time, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.message, style: TextStyle(color: AppColors.textSub, fontSize: 13, height: 1.4, fontWeight: n.read ? FontWeight.normal : FontWeight.w500)),
                  if (!n.read) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'assignment': return Icons.assignment_outlined;
      case 'cloud_sync': return Icons.sync;
      case 'alarm': return Icons.alarm;
      case 'manage_accounts': return Icons.manage_accounts_outlined;
      default: return Icons.notifications_none;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSub)),
          const SizedBox(height: 8),
          const Text('You\'ll see updates from admin here.', style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
