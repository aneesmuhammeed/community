import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class ExpenseBreakdown extends StatelessWidget {
  const ExpenseBreakdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final expenses = [
      {'label': 'Electricity', 'amount': 1200, 'icon': 'zap', 'bgColor': ext.warningSoft, 'iconColor': ext.warningForeground},
      {'label': 'Water', 'amount': 450, 'icon': 'droplets', 'bgColor': theme.colorScheme.secondary, 'iconColor': theme.colorScheme.primary},
      {'label': 'Housekeeping', 'amount': 800, 'icon': 'home', 'bgColor': ext.accentSoft, 'iconColor': const Color(0xFF10B981)},
      {'label': 'Security', 'amount': 500, 'icon': 'shield-check', 'bgColor': ext.aiSoft, 'iconColor': ext.ai},
      {'label': 'Repairs & Maint.', 'amount': 300, 'icon': 'wrench', 'bgColor': const Color(0xFFF1F5F9), 'iconColor': const Color(0xFF64748B)},
      {'label': 'Miscellaneous', 'amount': 250, 'icon': 'package', 'bgColor': const Color(0xFFE8EDF3), 'iconColor': const Color(0xFF64748B)},
    ];

    final total = expenses.fold<int>(0, (sum, item) => sum + (item['amount'] as int));

    return Column(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: expenses.length,
          itemBuilder: (context, i) {
            final e = expenses[i];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: e['bgColor'] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: CustomIcon(
                        icon: e['icon'] as String,
                        size: 16,
                        color: e['iconColor'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e['label'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${e['amount']}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // muted
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total This Month',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹$total',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
