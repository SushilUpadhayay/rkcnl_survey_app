import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isSyncing = false;

  void _handleSync() async {
    setState(() => _isSyncing = true);
    final success = await context.read<AppState>().syncAll();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Synchronization successful!'
              : 'Sync failed. Please check connection.'),
          backgroundColor: success ? AppColors.green : AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pending = appState.pendingItems;
    final history = appState.syncHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Synchronization',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildSyncStatus(appState),
              const SizedBox(height: 32),
              _buildPendingSection(pending),
              const SizedBox(height: 32),
              _buildHistorySection(history),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSyncStatus(AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: (appState.pendingCount > 0
                        ? AppColors.orange
                        : AppColors.green)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(
              appState.pendingCount > 0
                  ? Icons.cloud_upload_outlined
                  : Icons.cloud_done_outlined,
              color: appState.pendingCount > 0
                  ? AppColors.orange
                  : AppColors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            appState.pendingCount > 0
                ? '${appState.pendingCount} Items Pending'
                : 'All Data Synced',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            appState.lastSyncTime != null
                ? 'Last synced: ${DateFormat('MMM d, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(appState.lastSyncTime!))}'
                : 'Never synced yet',
            style: const TextStyle(color: AppColors.textSub, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed:
                appState.pendingCount > 0 && !_isSyncing ? _handleSync : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: appState.pendingCount > 0
                  ? AppColors.green
                  : AppColors.border,
            ),
            child: _isSyncing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.sync, size: 20),
                        SizedBox(width: 12),
                        Text('Sync Now')
                      ]),
          ),
          if (!appState.isOnline) ...[
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 14, color: AppColors.orange),
                SizedBox(width: 8),
                Text('No connection – upload unavailable',
                    style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPendingSection(List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending UploadQueue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Text('No pending items. You\'re all caught up!',
              style: TextStyle(color: AppColors.textMuted))
        else
          ...items.map((it) => _buildPendingItem(it)),
      ],
    );
  }

  Widget _buildPendingItem(Map<String, dynamic> it) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.outbox, color: AppColors.orange, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it['respondent'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(it['surveyTitle'],
                    style: const TextStyle(
                        color: AppColors.textSub, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.pending_outlined,
              color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<SyncHistoryItem> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sync History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        if (history.isEmpty)
          const Text('No sync history yet.',
              style: TextStyle(color: AppColors.textMuted))
        else
          ...history.reversed.take(5).map((h) => _buildHistoryItem(h)),
      ],
    );
  }

  Widget _buildHistoryItem(SyncHistoryItem h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.green, size: 18),
          const SizedBox(width: 12),
          Text('Synced ${h.count} record${h.count != 1 ? 's' : ''}',
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Text(
              DateFormat('MMM d, h:mm a')
                  .format(DateTime.fromMillisecondsSinceEpoch(h.timestamp)),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (i) {
        if (i == 0) context.go('/dashboard');
        if (i == 1) context.go('/surveys');
        if (i == 2) context.go('/sync');
        if (i == 3) context.go('/analytics');
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Surveys'),
        BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            activeIcon: Icon(Icons.sync),
            label: 'Sync'),
        BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            activeIcon: Icon(Icons.insights),
            label: 'Analytics'),
      ],
    );
  }
}
