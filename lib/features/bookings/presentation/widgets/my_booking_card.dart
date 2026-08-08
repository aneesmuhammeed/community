import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class MyBookingCard extends StatelessWidget {
  final String facility;
  final String date;
  final String time;
  final String status;
  final String icon;
  final bool canCancel;

  const MyBookingCard({
    Key? key,
    required this.facility,
    required this.date,
    required this.time,
    required this.status,
    required this.icon,
    this.canCancel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Color statusBgColor;
    Color statusTextColor;
    Color statusDotColor;
    String statusLabel;

    switch (status) {
      case 'cancelled':
        statusBgColor = const Color(0xFFFEE2E2); // dangerSoft
        statusTextColor = theme.colorScheme.error;
        statusDotColor = theme.colorScheme.error;
        statusLabel = 'Cancelled';
        break;
      case 'pending':
        statusBgColor = ext.warningSoft;
        statusTextColor = ext.warningForeground;
        statusDotColor = const Color(0xFFF59E0B); // warning
        statusLabel = 'Pending';
        break;
      case 'confirmed':
      default:
        statusBgColor = ext.accentSoft;
        statusTextColor = const Color(0xFF065F46); // accentSoftForeground
        statusDotColor = const Color(0xFF10B981); // accent
        statusLabel = 'Confirmed';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2850).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIcon(
                icon: icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        facility,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusDotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const CustomIcon(icon: 'calendar', size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const CustomIcon(icon: 'clock', size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (canCancel && status != 'cancelled') ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIcon(icon: 'x-circle', size: 13, color: theme.colorScheme.error),
                        const SizedBox(width: 4),
                        Text(
                          'Cancel Booking',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
