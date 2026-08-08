import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class OutstandingDuesCard extends StatelessWidget {
  final int amount;
  final String dueDate;
  final String status;

  const OutstandingDuesCard({
    Key? key,
    this.amount = 3500,
    this.dueDate = 'Dec 5, 2024',
    this.status = 'pending',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final isOverdue = status == 'overdue';
    final isPending = status == 'pending';

    List<Color> gradientColors;
    Color labelColor;
    String labelText;
    Color iconBgColor;
    Color iconColor;
    String iconName;

    if (isOverdue) {
      gradientColors = [const Color(0xFFFEE2E2), const Color(0xFFFECACA)]; // red-100 to red-200
      labelColor = const Color(0xFFB91C1C); // red-700
      labelText = 'OVERDUE';
      iconBgColor = theme.colorScheme.errorContainer;
      iconColor = theme.colorScheme.error;
      iconName = 'alert-circle';
    } else if (isPending) {
      gradientColors = [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)]; // amber-100 to amber-200
      labelColor = const Color(0xFFB45309); // amber-700
      labelText = 'PENDING';
      iconBgColor = ext.warningSoft;
      iconColor = ext.warningForeground;
      iconName = 'clock';
    } else {
      gradientColors = [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)]; // emerald-100 to emerald-200
      labelColor = const Color(0xFF15803D); // emerald-700
      labelText = 'PAID';
      iconBgColor = ext.accentSoft;
      iconColor = const Color(0xFF10B981); // accent
      iconName = 'check-circle';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2850).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelText,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹$amount',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIcon(
                      icon: iconName,
                      size: 20,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Due Date: $dueDate',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending || isOverdue
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.1),
                  foregroundColor: isPending || isOverdue
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isPending || isOverdue ? 'Pay Now' : 'View Receipt',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isPending || isOverdue
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
