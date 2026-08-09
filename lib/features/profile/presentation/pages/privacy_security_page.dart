import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isBiometricSupported = false;
  bool _biometricEnabled = false; // In a real app, load this from SecureStorage
  
  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    if (kIsWeb) return;
    
    try {
      final isSupported = await _auth.isDeviceSupported();
      setState(() {
        _isBiometricSupported = isSupported;
      });
    } catch (e) {
      debugPrint('Biometric check error: $e');
    }
  }

  Future<void> _toggleBiometrics(bool enable) async {
    if (enable) {
      try {
        final authenticated = await _auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          biometricOnly: true,
          persistAcrossBackgrounding: true,
        );
        if (authenticated) {
          setState(() => _biometricEnabled = true);
          // TODO: Save preference securely
        }
      } catch (e) {
        debugPrint('Biometric auth error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to authenticate')));
        }
      }
    } else {
      setState(() => _biometricEnabled = false);
      // TODO: Save preference securely
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is irreversible. All your data, bookings, and complaints will be permanently deleted. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deletion requested (Mocked for prototype)')),
        );
        // Mock sign out
        await Supabase.instance.client.auth.signOut();
        // The root auth stream will redirect to login page automatically
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
        title: Text('Privacy & Security', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 24, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(theme, 'Authentication'),
          if (_isBiometricSupported)
            SwitchListTile(
              title: Text('Biometric Login', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              subtitle: Text('Use FaceID / TouchID to unlock app', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              value: _biometricEnabled,
              activeColor: theme.colorScheme.primary,
              onChanged: _toggleBiometrics,
            ),
          ListTile(
            title: Text('Change Password', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
            trailing: const CustomIcon(icon: 'chevron-right', size: 18, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change password UI coming soon!')));
            },
          ),
          
          const Divider(height: 32),
          
          _buildSectionHeader(theme, 'Active Sessions (Mocked)'),
          ListTile(
            leading: Icon(Icons.phone_iphone, color: theme.colorScheme.primary),
            title: const Text('iPhone 13 (Current Device)'),
            subtitle: const Text('Bengaluru, India · Active now'),
          ),
          ListTile(
            leading: const Icon(Icons.laptop_mac, color: Colors.grey),
            title: const Text('MacBook Pro Web Browser'),
            subtitle: const Text('Bengaluru, India · Last active 2 hours ago'),
            trailing: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session revoked')));
              },
              child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ),
          
          const Divider(height: 32),
          
          _buildSectionHeader(theme, 'Danger Zone'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _handleDeleteAccount,
              icon: const CustomIcon(icon: 'alert-circle', color: Colors.white, size: 20),
              label: const Text('Delete Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
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
