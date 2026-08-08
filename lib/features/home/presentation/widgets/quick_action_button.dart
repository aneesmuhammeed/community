import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';

class QuickActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final String colorVariant;
  final VoidCallback? onTap;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.colorVariant = 'blue',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Color bgColor;
    Color iconColor;

    switch (colorVariant) {
      case 'green':
        bgColor = ext.accentSoft;
        iconColor = const Color(0xFF10B981); // accent green
        break;
      case 'purple':
        bgColor = ext.aiSoft;
        iconColor = ext.ai;
        break;
      case 'amber':
        bgColor = ext.warningSoft;
        iconColor = const Color(0xFFF59E0B); // warning
        break;
      case 'blue':
      default:
        bgColor = theme.colorScheme.secondary;
        iconColor = theme.colorScheme.primary;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: onTap ?? () {},
              child: Center(
                child: CustomIcon(
                  icon: icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
