import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class RespondentsScreen extends StatelessWidget {
  final String surveyId;
  const RespondentsScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tc = context.appColors;
    final survey = appState.surveys.firstWhere((s) => s.id == surveyId);
    final list = appState.getRespondents(surveyId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/surveys');
              }
            }),
        title: Text(survey.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: () => _showAddModal(context, appState, tc)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSurveyHeader(survey, tc),
            Expanded(
              child: list.isEmpty
                  ? _buildEmptyState(tc)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildRespondentTile(context, list[index], tc),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(context, appState, tc),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSurveyHeader(Survey s, AppThemeColors tc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: tc.isDark
          ? AppColors.green.withValues(alpha: 0.1)
          : AppColors.greenMid.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${s.id}: ${s.title}',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: tc.textPrimary)),
          const SizedBox(height: 4),
          Text('${s.region} • Due ${s.dueDate}',
              style: TextStyle(color: tc.textSub, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRespondentTile(
      BuildContext context, Respondent r, AppThemeColors tc) {
    final initials = r.name.length >= 2
        ? r.name.substring(0, 2).toUpperCase()
        : r.name.toUpperCase();
    final statusColor = r.status == RespondentStatus.completed
        ? AppColors.green
        : r.status == RespondentStatus.draft
            ? AppColors.blue
            : AppColors.orange;
    final statusLabel = r.status == RespondentStatus.completed
        ? 'Done'
        : r.status == RespondentStatus.draft
            ? 'Draft'
            : 'Pending';

    return InkWell(
      onTap: r.status == RespondentStatus.completed
          ? null
          : () => context.push('/form/$surveyId/${r.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tc.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: tc.greenLight,
              child: Text(initials,
                  style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: tc.textPrimary)),
                  Text(
                      '${r.phone ?? 'No phone'} • ${r.age != null ? 'Age ${r.age}' : 'Age N/A'}',
                      style: TextStyle(color: tc.textSub, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors tc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 64, color: tc.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No respondents yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: tc.textSub)),
          const SizedBox(height: 8),
          Text('Tap the + button to add your first respondent',
              textAlign: TextAlign.center,
              style: TextStyle(color: tc.textMuted)),
        ],
      ),
    );
  }

  void _showAddModal(
      BuildContext context, AppState appState, AppThemeColors tc) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    String? gender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
              color: tc.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: tc.border,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                Text('Add Respondent',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: tc.textPrimary)),
                const SizedBox(height: 24),
                _buildField('Full Name *', Icons.person_outline, nameCtrl,
                    'Respondent\'s full name', tc),
                _buildField('Phone Number', Icons.phone_outlined, phoneCtrl,
                    '+977 98XXXXXXXX', tc),
                Row(
                  children: [
                    Expanded(
                        child: _buildField(
                            'Age', Icons.cake_outlined, ageCtrl, 'Age', tc,
                            type: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: tc.textPrimary)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            items: ['Male', 'Female', 'Other']
                                .map((g) =>
                                    DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) => gender = v,
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12)),
                            hint: const Text('Select'),
                            dropdownColor: tc.surface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final r = await appState.addRespondent(
                      surveyId,
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      age: ageCtrl.text,
                      gender: gender,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.push('/form/$surveyId/${r.id}');
                    }
                  },
                  child: const Text('Add & Start Survey'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl,
      String hint, AppThemeColors tc,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: tc.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: type,
            decoration: InputDecoration(
                prefixIcon: Icon(icon, size: 20), hintText: hint),
          ),
        ],
      ),
    );
  }
}
