import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isExporting = false;

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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tc = context.appColors;

    return Scaffold(
      appBar: _buildAppBar(context, appState),
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKPISection(appState, tc),
              const SizedBox(height: 32),
              _buildChartSection(appState, tc),
              const SizedBox(height: 32),
              _buildRecentActivity(appState, tc),
              const SizedBox(height: 32),
              _buildExportButton(appState),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState appState) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Image.asset('assets/images/Krishi_Logo-Tr.png', width: 28, height: 28),
      ),
      title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => context.push('/notifications')),
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

  Widget _buildKPISection(AppState appState, AppThemeColors tc) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildKPICard('Total Surveys', appState.totalResponses.toString(), Icons.assignment, AppColors.blue, tc),
        _buildKPICard('Today', appState.todayCompleted.toString(), Icons.today, AppColors.green, tc),
        _buildKPICard('Pending Sync', appState.pendingCount.toString(), Icons.cloud_upload_outlined, AppColors.orange, tc),
        _buildKPICard('Synced', appState.syncedCount.toString(), Icons.cloud_done, AppColors.blue, tc),
      ],
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color, AppThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: tc.textPrimary)),
          Text(label, style: TextStyle(fontSize: 12, color: tc.textSub, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChartSection(AppState appState, AppThemeColors tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Survey Completion Status', tc),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tc.border),
          ),
          child: _buildPieChart(appState, tc),
        ),
        const SizedBox(height: 32),
        _buildSectionTitle('Weekly Submission Trend', tc),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(16, 32, 24, 16),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tc.border),
          ),
          child: _buildBarChart(appState, tc),
        ),
      ],
    );
  }

  Widget _buildPieChart(AppState appState, AppThemeColors tc) {
    final statusData = appState.getSurveyStatusData();
    final total = statusData.values.fold(0, (s, v) => s + v);

    if (total == 0) {
      return Center(child: Text('No data available', style: TextStyle(color: tc.textMuted)));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: statusData['Synced']!.toDouble(), title: 'Sync', color: AppColors.green, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: statusData['In Progress']!.toDouble(), title: 'Prog', color: AppColors.orange, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: statusData['Pending']!.toDouble(), title: 'Pend', color: AppColors.blue, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBarChart(AppState appState, AppThemeColors tc) {
    final trendData = appState.getWeeklyTrendData();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10, // Adjust based on data
        barGroups: trendData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['count'] as int).toDouble(),
                color: AppColors.green,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, _) => Text(trendData[val.toInt()]['day'], style: TextStyle(fontSize: 10, color: tc.textMuted)),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildRecentActivity(AppState appState, AppThemeColors tc) {
    final history = appState.syncHistory;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Sync Activity', tc),
        const SizedBox(height: 16),
        if (history.isEmpty)
          Text('No recent activity recorded.', style: TextStyle(color: tc.textMuted))
        else
          ...history.reversed.take(5).map((h) => _buildActivityItem(h, tc)),
      ],
    );
  }

  Widget _buildActivityItem(SyncHistoryItem h, AppThemeColors tc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tc.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: AppColors.green, child: Icon(Icons.sync, size: 16, color: Colors.white)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sync Complete: ${h.count} records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: tc.textPrimary)),
              Text(DateFormat('MMM d, h:mm a').format(DateTime.fromMillisecondsSinceEpoch(h.timestamp)), style: TextStyle(fontSize: 12, color: tc.textSub)),
            ],
          ),
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

  Widget _buildSectionTitle(String title, AppThemeColors tc) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: tc.textPrimary));
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
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
