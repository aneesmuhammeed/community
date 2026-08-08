import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final methods = [
      {'icon': 'smartphone', 'label': 'UPI', 'color': theme.colorScheme.secondary, 'iconColor': theme.colorScheme.primary},
      {'icon': 'credit-card', 'label': 'Credit/Debit Card', 'color': ext.accentSoft, 'iconColor': const Color(0xFF10B981)},
      {'icon': 'building-2', 'label': 'Net Banking', 'color': ext.warningSoft, 'iconColor': ext.warningForeground},
      {'icon': 'wallet', 'label': 'Digital Wallets', 'color': ext.aiSoft, 'iconColor': ext.ai},
    ];

    return Column(
      children: methods.map((m) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: m['color'] as Color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8EDF3)), // border
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: CustomIcon(
                        icon: m['icon'] as String,
                        size: 18,
                        color: m['iconColor'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      m['label'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const CustomIcon(
                    icon: 'chevron-right',
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
