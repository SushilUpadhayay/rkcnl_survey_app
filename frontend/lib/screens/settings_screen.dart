import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tc = context.appColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Appearance'),
              _buildSettingTile(
                'Dark Mode',
                'Adjust application theme',
                Icons.dark_mode_outlined,
                tc,
                Switch(
                    value: appState.darkMode,
                    activeThumbColor: AppColors.green,
                    onChanged: (v) => appState.setDarkMode(v)),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Data & Synchronization'),
              _buildSettingTile(
                'Auto-Sync',
                'Sync data when online',
                Icons.sync,
                tc,
                Switch(
                    value: appState.autoSync,
                    activeThumbColor: AppColors.green,
                    onChanged: (v) => appState.setAutoSync(v)),
              ),
              Divider(color: tc.border),
              _buildSettingTile(
                'Language',
                'Nepali / English (Coming soon)',
                Icons.language,
                tc,
                Text('English',
                    style: TextStyle(
                        color: tc.textMuted, fontWeight: FontWeight.bold)),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Storage'),
              _buildSettingTile(
                'Clear local cache',
                'Deletes non-pending responses',
                Icons.delete_outline,
                tc,
                Icon(Icons.chevron_right, color: tc.textMuted),
                onTap: () => _confirmClearCache(context, appState, tc),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8, left: 52),
                child: Text(
                  'Storage used: ${((appState.storage.storageUsedBytes()) / 1024).toStringAsFixed(2)} KB',
                  style: TextStyle(
                      color: tc.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('About'),
              _buildSettingTile(
                  'App Version',
                  'Build #2026.03.02',
                  Icons.info_outline,
                  tc,
                  Text('1.0.0',
                      style: TextStyle(
                          color: tc.textMuted, fontWeight: FontWeight.bold))),
              Divider(color: tc.border),
              _buildSettingTile(
                  'Privacy Policy',
                  'Read our data terms',
                  Icons.policy_outlined,
                  tc,
                  Icon(Icons.chevron_right, size: 20, color: tc.textMuted),
                  onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildSettingTile(String title, String sub, IconData icon,
      AppThemeColors tc, Widget trailing,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: tc.surfaceVariant, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: tc.textPrimary)),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: tc.textPrimary)),
      subtitle: Text(sub, style: TextStyle(color: tc.textSub, fontSize: 13)),
      trailing: trailing,
    );
  }

  void _confirmClearCache(
      BuildContext context, AppState appState, AppThemeColors tc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
            'This will remove all locally stored survey responses that have already been synced. Pending items will remain.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                await appState.storage.clearCache();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cache cleared')));
                }
              },
              child: const Text('Clear',
                  style: TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
