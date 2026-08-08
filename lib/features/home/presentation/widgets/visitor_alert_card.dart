import 'package:flutter/material.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';

class VisitorCard extends StatelessWidget {
  final String name;
  final String time;
  final String purpose;
  final String status;
  final String gender;
  final String heritage;
  final int index;

  const VisitorCard({
    Key? key,
    required this.name,
    required this.time,
    required this.purpose,
    this.status = 'pending',
    this.gender = 'female',
    this.heritage = 'South Asian',
    this.index = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Color dotColor;
    Color bgColor;
    Color textColor;
    String statusLabel;

    switch (status) {
      case 'approved':
        dotColor = ext.accentSoftForeground; // assuming accent for dot
        bgColor = ext.accentSoft;
        textColor = ext.accentSoftForeground;
        statusLabel = 'Approved';
        break;
      case 'arrived':
        dotColor = theme.colorScheme.primary;
        bgColor = theme.colorScheme.secondary;
        textColor = AppColors.secondaryForeground;
        statusLabel = 'Arrived';
        break;
      case 'pending':
      default:
        dotColor = theme.colorScheme.error; // Fallback to orange/warning
        bgColor = ext.warningSoft;
        textColor = ext.warningForeground;
        statusLabel = 'Awaiting';
        break;
    }

    // specific override for warning as dotColor is warning
    if (status == 'pending') {
       dotColor = ext.warningForeground;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2850).withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          UserAvatar(
            gender: gender,
            ageGroup: '25-35',
            heritage: heritage,
            index: index,
            size: 40,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$purpose · $time',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
