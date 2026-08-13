import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Help & Support', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 24, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader(theme, 'Contact Society Manager'),
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.primary),
            title: const Text('Rakesh Kumar (Manager)'),
            subtitle: const Text('Available Mon-Sat, 9AM to 6PM'),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Call Office'),
            subtitle: const Text('+91 98765 43210'),
            onTap: () async {
              final Uri url = Uri.parse('tel:123456789');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text('Email Society'),
            subtitle: const Text('manager@prestige-estates.com'),
            onTap: () async {
              final Uri url = Uri.parse('mailto:manager@prestige-estates.com?subject=App%20Inquiry');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),

          const Divider(height: 32),

          _buildSectionHeader(theme, 'Emergency Contacts'),
          ListTile(
            leading: const Icon(Icons.local_hospital, color: Colors.red),
            title: const Text('Nearest Hospital / Ambulance'),
            subtitle: const Text('108 or +91 80 4567 8900'),
            trailing: const CustomIcon(icon: 'chevron-right', size: 18, color: Colors.grey),
            onTap: () async {
              final Uri url = Uri.parse('tel:108');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.orange),
            title: const Text('Main Gate Security'),
            subtitle: const Text('Intercom: 9999 or +91 80 1234 5678'),
            trailing: const CustomIcon(icon: 'chevron-right', size: 18, color: Colors.grey),
            onTap: () async {
              final Uri url = Uri.parse('tel:+918012345678');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),

          const Divider(height: 32),

          _buildSectionHeader(theme, 'App Support'),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.purple),
            title: const Text('Report an App Issue'),
            subtitle: const Text('Found a bug? Let us know.'),
            trailing: const CustomIcon(icon: 'chevron-right', size: 18, color: Colors.grey),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Report an Issue'),
                  content: const TextField(
                    decoration: InputDecoration(hintText: 'Describe the issue...'),
                    maxLines: 3,
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported successfully')));
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.teal),
            title: const Text('Frequently Asked Questions'),
            subtitle: const Text('Guides on how to use the app.'),
            trailing: const CustomIcon(icon: 'chevron-right', size: 18, color: Colors.grey),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FaqPage()));
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
