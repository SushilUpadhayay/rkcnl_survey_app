import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key});

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  final _searchController = TextEditingController();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final list = _getFilteredSurveys(appState.surveys);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Surveys', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: false,
        actions: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.green,
              child: Text(appState.userInitials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            Expanded(
              child: list.isEmpty 
                ? _buildEmptyState() 
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: list.length,
                    itemBuilder: (context, index) => _buildSurveyCard(context, list[index], appState),
                  ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: 'Search surveys by name or ID...',
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => _searchController.clear()))
                : null,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPill('All Surveys', 'all'),
                _buildPill('In Progress', 'inProgress'),
                _buildPill('Pending', 'pending'),
                _buildPill('Synced', 'synced'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String value) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.green : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSub,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, Survey s, AppState appState) {
    final respondents = appState.getRespondents(s.id);
    final count = respondents.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/respondents/${s.id}'),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(s.colorValue).withOpacity(0.9), Color(s.colorValue).withOpacity(0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(_getIcon(s.iconName), color: Colors.white, size: 40),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                    child: Text(s.id, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(s.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
                      _buildStatusBadge(s.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMetaItem(Icons.location_on_outlined, s.region),
                  _buildMetaItem(Icons.calendar_today_outlined, 'Due ${s.dueDate}'),
                  _buildMetaItem(Icons.priority_high, '${s.priority[0].toUpperCase()}${s.priority.substring(1)} Priority', color: _getPriorityColor(s.priority)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 16, color: AppColors.green),
                      const SizedBox(width: 8),
                      Text('$count response${count != 1 ? 's' : ''} collected', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: s.status == SurveyStatus.synced ? null : () => context.push('/respondents/${s.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: s.status == SurveyStatus.synced ? AppColors.border : AppColors.green,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(
                      s.status == SurveyStatus.synced ? 'Completed & Synced' : (s.status == SurveyStatus.inProgress ? 'Continue Collection' : 'Start Collection'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(SurveyStatus status) {
    final label = status == SurveyStatus.inProgress ? 'In Progress' : status == SurveyStatus.synced ? 'Synced' : 'Pending';
    final color = status == SurveyStatus.inProgress ? AppColors.blue : status == SurveyStatus.synced ? AppColors.green : AppColors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: color ?? AppColors.textSub, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No surveys found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textSub)),
            const SizedBox(height: 8),
            const Text('Try adjusting your search or filters.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  List<Survey> _getFilteredSurveys(List<Survey> source) {
    return source.where((s) {
      final matchesFilter = _filter == 'all' || s.status.name == _filter;
      final q = _searchController.text.toLowerCase();
      final matchesSearch = q.isEmpty || s.title.toLowerCase().contains(q) || s.id.toLowerCase().contains(q) || s.region.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'eco': return Icons.eco;
      case 'water_drop': return Icons.water_drop;
      case 'water': return Icons.water;
      case 'pets': return Icons.pets;
      case 'warehouse': return Icons.warehouse;
      default: return Icons.assignment;
    }
  }

  Color _getPriorityColor(String p) {
    if (p == 'high') return AppColors.red;
    if (p == 'medium') return AppColors.orange;
    return AppColors.green;
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
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
