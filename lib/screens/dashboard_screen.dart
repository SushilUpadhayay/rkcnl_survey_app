import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return Scaffold(
      appBar: _buildAppBar(context, appState),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => appState.syncAll(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBanner(appState),
                if (!appState.isOnline) _buildOfflineBanner(),
                const SizedBox(height: 24),
                _buildSectionHeader(Icons.bar_chart, 'Survey Statistics'),
                const SizedBox(height: 12),
                _buildStatsGrid(appState),
                const SizedBox(height: 32),
                _buildSectionHeader(Icons.bolt, 'Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 32),
                _buildSectionHeader(Icons.history, 'Recent Activity'),
                const SizedBox(height: 12),
                _buildRecentActivity(appState),
                const SizedBox(height: 80), // Padding for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState appState) {
    return AppBar(
      leading: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Image.network(
          'https://rastriyakrishi.com.np/wp-content/uploads/2024/07/Krishi_Logo-Tr.png',
          width: 28,
          height: 28,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.agriculture, color: AppColors.green, size: 24),
        ),
      ),
      title: const Text('Rastriye Krishi', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () => context.push('/notifications'),
            ),
            if (appState.unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${appState.unreadCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.green,
            child: Text(appState.userInitials, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWelcomeBanner(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(appState.userName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text('Assigned: ${appState.userRegion}', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.eco, color: Colors.white24, size: 64),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.orange.withOpacity(0.3))),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: AppColors.orange, size: 18),
          SizedBox(width: 12),
          Text('Offline Mode – Data saved locally', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildStatsGrid(AppState appState) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildStatCard('Assigned', '${appState.surveys.where((s) => s.status != SurveyStatus.synced).length}', 'Active', AppColors.green),
        _buildStatCard('Finished', '${appState.todayCompleted}', '+2%', AppColors.blue),
        _buildStatCard('Pending', '${appState.pendingCount}', appState.pendingCount > 0 ? 'Upload' : 'Clear', appState.pendingCount > 0 ? AppColors.orange : AppColors.textMuted),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String badge, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSub, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(badge, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(context, Icons.assignment_add, 'View Surveys', 'View and fill assigned surveys', AppColors.green, '/surveys'),
        const SizedBox(height: 12),
        _buildActionTile(context, Icons.cloud_sync, 'Sync Data', 'Upload saved offline responses', AppColors.blue, '/sync'),
        const SizedBox(height: 12),
        _buildActionTile(context, Icons.insights, 'Analytics', 'View your submission summary', AppColors.purple, '/analytics'),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, String sub, Color color, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(color: AppColors.textSub, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(AppState appState) {
    // Collect all respondents sorted by time
    final List<Map<String, dynamic>> allActivity = [];
    for (final s in appState.surveys) {
      final resps = appState.getRespondents(s.id);
      for (final r in resps) {
        allActivity.add({
          'name': r.name,
          'survey': s.title,
          'time': r.completedAt ?? r.startedAt,
          'status': r.status,
        });
      }
    }
    allActivity.sort((a, b) => (b['time'] as int).compareTo(a['time'] as int));
    final display = allActivity.take(5).toList();

    if (display.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text('No recent activity yet.', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    return Column(
      children: display.map((a) => _buildActivityItem(a)).toList(),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> item) {
    final status = item['status'] as RespondentStatus;
    final color = status == RespondentStatus.completed ? AppColors.green : status == RespondentStatus.draft ? AppColors.blue : AppColors.orange;
    final timeStr = _formatTimeAgo(item['time'] as int);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(item['survey'], style: const TextStyle(color: AppColors.textSub, fontSize: 12)),
              ],
            ),
          ),
          Text(timeStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTimeAgo(int ts) {
    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildBottomNav(BuildContext context, int index) {
    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        if (i == 0) context.go('/dashboard');
        if (i == 1) context.go('/surveys');
        if (i == 2) context.go('/sync');
        if (i == 3) context.go('/analytics');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Surveys'),
        BottomNavigationBarItem(icon: Icon(Icons.sync), activeIcon: Icon(Icons.sync), label: 'Sync'),
        BottomNavigationBarItem(icon: Icon(Icons.insights), activeIcon: Icon(Icons.insights), label: 'Analytics'),
      ],
    );
  }
}
