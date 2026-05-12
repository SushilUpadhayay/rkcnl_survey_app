import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

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
                Switch(
                    value: appState.autoSync,
                    activeThumbColor: AppColors.green,
                    onChanged: (v) => appState.setAutoSync(v)),
              ),
              const Divider(),
              _buildSettingTile(
                'Language',
                'Nepali / English (Coming soon)',
                Icons.language,
                const Text('English',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold)),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Storage'),
              _buildSettingTile(
                'Clear local cache',
                'Deletes non-pending responses',
                Icons.delete_outline,
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
                onTap: () => _confirmClearCache(context, appState),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8, left: 52),
                child: Text(
                  'Storage used: ${((appState.storage.storageUsedBytes()) / 1024).toStringAsFixed(2)} KB',
                  style: const TextStyle(
                      color: AppColors.textMuted,
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
                  const Text('1.0.0',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.bold))),
              const Divider(),
              _buildSettingTile(
                  'Privacy Policy',
                  'Read our data terms',
                  Icons.policy_outlined,
                  const Icon(Icons.chevron_right, size: 20),
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

  Widget _buildSettingTile(
      String title, String sub, IconData icon, Widget trailing,
      {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.textPrimary)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      subtitle: Text(sub,
          style: const TextStyle(color: AppColors.textSub, fontSize: 13)),
      trailing: trailing,
    );
  }

  void _confirmClearCache(BuildContext context, AppState appState) {
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
