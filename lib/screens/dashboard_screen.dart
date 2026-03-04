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
                if (!appState.isOnline) _buildOfflineBanner(context),
                const SizedBox(height: 24),
                _buildSectionHeader(context, Icons.bar_chart, 'Survey Statistics'),
                const SizedBox(height: 12),
                _buildStatsGrid(context, appState),
                const SizedBox(height: 32),
                _buildSectionHeader(context, Icons.bolt, 'Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 32),
                _buildSectionHeader(context, Icons.history, 'Recent Activity'),
                const SizedBox(height: 12),
                _buildRecentActivity(context, appState),
                const SizedBox(height: 80),
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
        padding: const EdgeInsets.only(left: 16),
        child: Image.asset(
          'assets/images/Krishi_Logo-Tr.png',
          width: 28,
          height: 28,
        ),
      ),
      title: const Text('Rastriye Krishi',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
                  decoration: const BoxDecoration(
                      color: AppColors.orange, shape: BoxShape.circle),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${appState.unreadCount}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold),
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
            child: Text(appState.userInitials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
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
        gradient: const LinearGradient(
          colors: [AppColors.green, AppColors.greenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                appState.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white70,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Assigned: ${appState.userRegion}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.eco,
                color: Colors.white24,
                size: 64,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final tc = context.appColors;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
          color: AppColors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.orange.withValues(alpha: 0.3))),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: AppColors.orange, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Offline Mode – Data saved locally',
                style: TextStyle(
                    color: tc.isDark ? AppColors.orange : AppColors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    final tc = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 18, color: tc.textPrimary),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary)),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, AppState appState) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildStatCard(
            context,
            'Assigned',
            '${appState.surveys.where((s) => s.status != SurveyStatus.synced).length}',
            'Active',
            AppColors.green),
        _buildStatCard(
            context, 'Finished', '${appState.todayCompleted}', '+2%', AppColors.blue),
        _buildStatCard(
            context,
            'Pending',
            '${appState.pendingCount}',
            appState.pendingCount > 0 ? 'Upload' : 'Clear',
            appState.pendingCount > 0 ? AppColors.orange : AppColors.textMuted),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, String badge, Color color) {
    final tc = context.appColors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: tc.textSub,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: tc.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(badge,
                  style: TextStyle(
                      color: color, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(context, Icons.assignment_add, 'View Surveys',
            'View and fill assigned surveys', AppColors.green, '/surveys'),
        const SizedBox(height: 12),
        _buildActionTile(context, Icons.cloud_sync, 'Sync Data',
            'Upload saved offline responses', AppColors.blue, '/sync'),
        const SizedBox(height: 12),
        _buildActionTile(context, Icons.insights, 'Analytics',
            'View your submission summary', AppColors.purple, '/analytics'),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title,
      String sub, Color color, String route) {
    final tc = context.appColors;
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tc.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: tc.isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: tc.textPrimary)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(
                          color: tc.textSub, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: tc.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppState appState) {
    final tc = context.appColors;
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text('No recent activity yet.',
              style: TextStyle(color: tc.textMuted)),
        ),
      );
    }

    return Column(
      children: display.map((a) => _buildActivityItem(context, a)).toList(),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> item) {
    final tc = context.appColors;
    final status = item['status'] as RespondentStatus;
    final color = status == RespondentStatus.completed
        ? AppColors.green
        : status == RespondentStatus.draft
            ? AppColors.blue
            : AppColors.orange;
    final timeStr = _formatTimeAgo(item['time'] as int);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: tc.textPrimary)),
                Text(item['survey'],
                    style: TextStyle(
                        color: tc.textSub, fontSize: 12)),
              ],
            ),
          ),
          Text(timeStr,
              style: TextStyle(color: tc.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTimeAgo(int ts) {
    final diff =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
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
