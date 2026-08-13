import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('FAQs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 24, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(theme, 'How do I raise a complaint?', 'Go to the "My Complaints" section from the home or profile tab and tap the floating action button to create a new complaint. You can track its status there.'),
          _buildFaqItem(theme, 'How can I add family members?', 'Navigate to Profile -> Family Members and tap the add button. You will need to provide their basic details.'),
          _buildFaqItem(theme, 'How do I book an amenity?', 'Go to the Bookings tab, select an amenity (like the pool or clubhouse), choose a date and time slot, and confirm your booking.'),
          _buildFaqItem(theme, 'Who can I contact for emergencies?', 'Check the "Help & Support" page for emergency contacts including the nearest hospital and main gate security.'),
          _buildFaqItem(theme, 'How do I reset my password?', 'You can request a password reset from the login screen, or change it directly in the Privacy & Security section if you are already logged in.'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(ThemeData theme, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
