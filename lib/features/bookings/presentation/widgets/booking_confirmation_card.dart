import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class BookingConfirmationCard extends StatelessWidget {
  final String facility;
  final String date;
  final String time;
  final int fee;
  final String icon;

  const BookingConfirmationCard({
    Key? key,
    this.facility = 'Clubhouse',
    this.date = 'December 14, 2024',
    this.time = '6:00 PM – 9:00 PM',
    this.fee = 500,
    this.icon = 'building',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF3)), // border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2850).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top accent strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                CustomIcon(icon: icon, size: 18, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text(
                  'Confirm Booking',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow(context, 'Facility', facility, icon),
                const SizedBox(height: 12),
                _buildRow(context, 'Date', date, 'calendar'),
                const SizedBox(height: 12),
                _buildRow(context, 'Time', time, 'clock'),
                const SizedBox(height: 12),
                _buildRow(context, 'Booking Fee', '₹$fee', 'indian-rupee', highlight: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9), // muted
                          foregroundColor: const Color(0xFF64748B), // mutedForeground
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIcon(icon: 'check', size: 16, color: theme.colorScheme.onPrimary),
                            const SizedBox(width: 8),
                            Text(
                              'Confirm Booking',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, String icon, {bool highlight = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CustomIcon(icon: icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
