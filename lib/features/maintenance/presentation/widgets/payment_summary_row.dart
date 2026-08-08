import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class PaymentSummaryRow extends StatelessWidget {
  final int paidThisYear;
  final int pendingAmount;
  final String nextDueDate;

  const PaymentSummaryRow({
    Key? key,
    this.paidThisYear = 42000,
    this.pendingAmount = 3500,
    this.nextDueDate = 'Dec 5, 2024',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryBox(
            context,
            icon: 'check-circle',
            iconColor: theme.colorScheme.primary,
            bgColor: theme.colorScheme.secondary,
            label: 'Paid This Year',
            value: '₹$paidThisYear',
            valueColor: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryBox(
            context,
            icon: 'alert-circle',
            iconColor: ext.warningForeground,
            bgColor: ext.warningSoft,
            label: 'Pending',
            value: '₹$pendingAmount',
            valueColor: ext.warningForeground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryBox(
            context,
            icon: 'calendar',
            iconColor: const Color(0xFF10B981), // accent
            bgColor: ext.accentSoft,
            label: 'Next Due',
            value: nextDueDate,
            valueColor: const Color(0xFF065F46), // accentSoftForeground
            isDate: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBox(
    BuildContext context, {
    required String icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required Color valueColor,
    bool isDate = false,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIcon(icon: icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B), // mutedForeground
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: isDate ? 14 : 20,
              height: isDate ? 1.4 : null,
            ),
          ),
        ],
      ),
    );
  }
}
