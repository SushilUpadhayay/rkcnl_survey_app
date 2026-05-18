import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isExporting = false;

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

    return Scaffold(
      appBar: _buildAppBar(context, appState),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(appState),
              const SizedBox(height: 32),
              const Text('Collection Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _buildChartSection(appState),
              const SizedBox(height: 32),
              const Text('Survey Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ...appState.surveys.map((s) => _buildSurveyProgress(s, appState)),
              const SizedBox(height: 24),
              _buildExportButton(appState),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildOverviewCards(AppState appState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildSmallInfoCard(
                    'Total Responses',
                    '${appState.totalResponses}',
                    Icons.groups_outlined,
                    AppColors.blue)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildSmallInfoCard(
                    'Completed',
                    '${appState.completedResponses}',
                    Icons.check_circle_outlined,
                    AppColors.green)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildSmallInfoCard('Synced', '${appState.syncedCount}',
                    Icons.cloud_done_outlined, AppColors.green)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildSmallInfoCard(
                    'Pending Sync',
                    '${appState.pendingCount}',
                    Icons.cloud_upload_outlined,
                    AppColors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard(
      String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(val,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSub,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChartSection(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Responses per Survey',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Last 30 Days',
                  style: TextStyle(
                      color: AppColors.textMuted,
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
                    s.id.split('-').last, count, max, Color(s.colorValue));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int val, int max, Color color) {
    final height = (val / max) * 120 + 10;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('$val',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textSub)),
      ],
    );
  }

  Widget _buildSurveyProgress(Survey s, AppState appState) {
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
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14))),
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
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border),
          ),
          const SizedBox(height: 6),
          Text('$completed completed of ${respondents.length} total',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSub,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildExportButton(AppState appState) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: appState.totalResponses > 0 && !_isExporting
            ? () => _handleExport(appState)
            : null,
        icon: _isExporting
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.ios_share_outlined, size: 18),
        label: Text(_isExporting ? 'Preparing CSV...' : 'Export All Data as CSV'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: AppColors.green),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _handleExport(AppState appState) async {
    setState(() => _isExporting = true);
    final success = await appState.exportSyncedData();
    if (mounted) {
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'CSV ready — choose an app to share.'
              : 'Export failed. Please try again.'),
          backgroundColor: success ? AppColors.green : AppColors.red,
        ),
      );
    }
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      onTap: (i) {
        if (i == 0) context.go('/dashboard');
        if (i == 1) context.go('/surveys');
        if (i == 2) context.go('/sync');
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
      ],
    );
  }
}
