import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState appState) {
    return AppBar(
      title: const Text(
        'Field Insights',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      centerTitle: false,
      actions: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.green,
            child: Text(
              appState.userInitials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tc = context.appColors;

    return Scaffold(
      appBar: _buildAppBar(context, appState),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(context, appState, tc),
              const SizedBox(height: 32),
              Text('Collection Progress',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: tc.textPrimary)),
              const SizedBox(height: 16),
              _buildChartSection(context, appState, tc),
              const SizedBox(height: 32),
              Text('Survey Breakdown',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: tc.textPrimary)),
              const SizedBox(height: 16),
              ...appState.surveys
                  .map((s) => _buildSurveyProgress(s, appState, tc)),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 3),
    );
  }

  Widget _buildOverviewCards(
      BuildContext context, AppState appState, AppThemeColors tc) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildSmallInfoCard(
                    'Total Responses',
                    '${appState.totalResponses}',
                    Icons.groups_outlined,
                    AppColors.blue,
                    tc)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildSmallInfoCard(
                    'Completed',
                    '${appState.completedResponses}',
                    Icons.check_circle_outlined,
                    AppColors.green,
                    tc)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildSmallInfoCard('Synced', '${appState.syncedCount}',
                    Icons.cloud_done_outlined, AppColors.green, tc)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildSmallInfoCard(
                    'Pending Sync',
                    '${appState.pendingCount}',
                    Icons.cloud_upload_outlined,
                    AppColors.orange,
                    tc)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(
      String label, String val, IconData icon, Color color, AppThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(val,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: tc.textPrimary)),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: tc.textSub,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChartSection(
      BuildContext context, AppState appState, AppThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Responses per Survey',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: tc.textPrimary)),
              Text('Last 30 Days',
                  style: TextStyle(
                      color: tc.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: appState.surveys.take(5).map((s) {
                final count = appState.getRespondents(s.id).length;
                final max = appState.surveys.fold<int>(1, (m, sv) {
                  final c = appState.getRespondents(sv.id).length;
                  return c > m ? c : m;
                });
                return _buildBar(
                    s.id.split('-').last, count, max, Color(s.colorValue), tc);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
      String label, int val, int max, Color color, AppThemeColors tc) {
    final height = (val / max) * 120 + 10;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$val',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: tc.textPrimary)),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4))),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.bold, color: tc.textSub)),
      ],
    );
  }

  Widget _buildSurveyProgress(Survey s, AppState appState, AppThemeColors tc) {
    final respondents = appState.getRespondents(s.id);
    final completed =
        respondents.where((r) => r.status == RespondentStatus.completed).length;
    final total = respondents.isEmpty ? 1 : respondents.length;
    final progress = completed / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: tc.textPrimary))),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                value: progress, minHeight: 8, backgroundColor: tc.border),
          ),
          const SizedBox(height: 6),
          Text('$completed completed of ${respondents.length} total',
              style: TextStyle(
                  fontSize: 11,
                  color: tc.textSub,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int currentIndex) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
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
