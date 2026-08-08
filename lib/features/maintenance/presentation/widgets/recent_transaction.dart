import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class RecentTransaction extends StatelessWidget {
  final String date;
  final int amount;
  final String method;
  final String methodType;
  final String status;
  final String refNo;

  const RecentTransaction({
    Key? key,
    this.date = 'Nov 25, 2024',
    this.amount = 3500,
    this.method = 'UPI (GooglePay)',
    this.methodType = 'upi',
    this.status = 'success',
    this.refNo = '#TXN20241125001',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    String methodIcon;
    switch (methodType) {
      case 'upi':
        methodIcon = 'smartphone';
        break;
      case 'card':
        methodIcon = 'credit-card';
        break;
      case 'netbanking':
        methodIcon = 'building-2';
        break;
      case 'wallet':
        methodIcon = 'wallet';
        break;
      default:
        methodIcon = 'credit-card';
        break;
    }

    Color bgColor;
    Color textColor;
    String statusIcon;
    String statusLabel;

    switch (status) {
      case 'failed':
        bgColor = const Color(0xFFFEE2E2); // dangerSoft
        textColor = theme.colorScheme.error;
        statusIcon = 'x-circle';
        statusLabel = 'Failed';
        break;
      case 'pending':
        bgColor = ext.warningSoft;
        textColor = ext.warningForeground;
        statusIcon = 'clock';
        statusLabel = 'Pending';
        break;
      case 'success':
      default:
        bgColor = ext.accentSoft;
        textColor = const Color(0xFF065F46); // accentSoftForeground
        statusIcon = 'check-circle';
        statusLabel = 'Success';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8EDF3),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // muted
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIcon(
                icon: methodIcon,
                size: 18,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maintenance Bill',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      method,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('·', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                    ),
                    Text(
                      date,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  refNo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIcon(
                      icon: statusIcon,
                      size: 12,
                      color: textColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
