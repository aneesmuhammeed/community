import '../../../../core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../data/profile_repository.dart';

class NotificationsSettingsPage extends ConsumerStatefulWidget {
  const NotificationsSettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends ConsumerState<NotificationsSettingsPage> {
  bool _isLoading = true;
  bool _globalPushEnabled = true;
  bool _announcementsEnabled = true;
  final _repository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final response = await _repository.getNotificationSettings(ref.read(userProvider)!.residentId);

      if (response != null) {
        setState(() {
          _globalPushEnabled = response['global_push_enabled'] ?? true;
          _announcementsEnabled = response['announcements_enabled'] ?? true;
        });
      } else {
        // If no settings row exists yet, we insert one
        await _repository.createDefaultNotificationSettings(ref.read(userProvider)!.residentId);
      }
    } catch (e) {
      debugPrint('Error fetching notification settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading settings: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    try {
      await _repository.updateNotificationSetting(ref.read(userProvider)!.residentId, key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update setting: $e')));
        // Revert UI change
        setState(() {
          if (key == 'global_push_enabled') _globalPushEnabled = !value;
          if (key == 'announcements_enabled') _announcementsEnabled = !value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Notifications', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 24, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionHeader(theme, 'Push Notifications'),
                SwitchListTile(
                  title: Text('Global Push Notifications', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  subtitle: Text('Allow app to send push notifications', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  value: _globalPushEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _globalPushEnabled = val);
                    _updateSetting('global_push_enabled', val);
                  },
                ),
                const Divider(height: 32),
                _buildSectionHeader(theme, 'Updates & Alerts'),
                SwitchListTile(
                  title: Text('Announcements & Notices', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  subtitle: Text('Get notified about admin circulars and maintenance alerts', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  value: _announcementsEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _announcementsEnabled = val);
                    _updateSetting('announcements_enabled', val);
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
