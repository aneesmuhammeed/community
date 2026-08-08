import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class FacilityCard extends StatelessWidget {
  final String name;
  final String status;
  final int capacity;
  final String hours;
  final String icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const FacilityCard({
    Key? key,
    required this.name,
    this.status = 'available',
    required this.capacity,
    required this.hours,
    required this.icon,
    this.isSelected = false,
    this.onTap,
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
      case 'booked':
        statusBgColor = const Color(0xFFFEE2E2); // dangerSoft
        statusTextColor = theme.colorScheme.error;
        statusDotColor = theme.colorScheme.error;
        statusLabel = 'Fully Booked';
        break;
      case 'limited':
        statusBgColor = ext.warningSoft;
        statusTextColor = ext.warningForeground;
        statusDotColor = const Color(0xFFF59E0B); // warning
        statusLabel = 'Limited Slots';
        break;
      case 'available':
      default:
        statusBgColor = ext.accentSoft;
        statusTextColor = const Color(0xFF065F46); // accentSoftForeground
        statusDotColor = const Color(0xFF10B981); // accent
        statusLabel = 'Available';
        break;
    }

    final isBooked = status == 'booked';

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : const Color(0xFFE8EDF3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2850).withOpacity(isSelected ? 0.15 : 0.07),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with status badge
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Stack(
              children: [
                Center(
                  child: CustomIcon(
                    icon: icon,
                    size: 32,
                    color: const Color(0xFF94A3B8), // slate-400
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
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
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CustomIcon(icon: 'users', size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      capacity.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const CustomIcon(icon: 'clock', size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        hours,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isBooked ? null : (onTap ?? () {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBooked 
                          ? const Color(0xFFF1F5F9) 
                          : isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.primary.withOpacity(0.1),
                      foregroundColor: isBooked 
                          ? const Color(0xFF64748B) 
                          : isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isBooked ? 'Unavailable' : isSelected ? 'Selected' : 'Select',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isBooked 
                            ? const Color(0xFF64748B) 
                            : isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
