import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class BillingHistoryItem extends StatelessWidget {
  final String month;
  final int amount;
  final String dueDate;
  final String status;
  final String paidDate;

  const BillingHistoryItem({
    Key? key,
    this.month = 'November 2024',
    this.amount = 3500,
    this.dueDate = 'Nov 30, 2024',
    this.status = 'paid',
    this.paidDate = 'Nov 28, 2024',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Color bgColor;
    Color textColor;
    Color dotColor;
    String labelText;

    switch (status) {
      case 'overdue':
        bgColor = const Color(0xFFFEE2E2); // dangerSoft
        textColor = theme.colorScheme.error;
        dotColor = theme.colorScheme.error;
        labelText = 'Overdue';
        break;
      case 'pending':
        bgColor = ext.warningSoft;
        textColor = ext.warningForeground;
        dotColor = const Color(0xFFF59E0B); // warning
        labelText = 'Pending';
        break;
      case 'paid':
      default:
        bgColor = ext.accentSoft;
        textColor = const Color(0xFF065F46); // accentSoftForeground
        dotColor = const Color(0xFF10B981); // accent
        labelText = 'Paid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8EDF3), // border
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹$amount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('·', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    ),
                    Text(
                      dueDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
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
                      labelText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {},
                child: const CustomIcon(
                  icon: 'download',
                  size: 16,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
