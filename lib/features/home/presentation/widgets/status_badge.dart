import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String variant;

  const StatusBadge({
    Key? key,
    required this.label,
    this.variant = 'info',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Color bgColor;
    Color textColor;

    switch (variant) {
      case 'warning':
        bgColor = ext.warningSoft;
        textColor = ext.warningForeground;
        break;
      case 'danger':
        bgColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.error;
        break;
      case 'success':
      case 'info':
      default:
        bgColor = ext.accentSoft;
        textColor = ext.accentSoftForeground;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
