import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final int selectedIndex;
  final ValueChanged<int>? onSlotSelected;

  const TimeSlotGrid({
    Key? key,
    required this.slots,
    this.selectedIndex = -1,
    this.onSlotSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: slots.length,
      itemBuilder: (context, i) {
        final slot = slots[i];
        final isAvailable = slot['available'] as bool;
        final isSelected = i == selectedIndex && isAvailable;

        Color bgColor;
        Color borderColor;
        Color textColor;
        String icon;
        Color iconColor;

        if (!isAvailable) {
          bgColor = const Color(0xFFF1F5F9); // muted
          borderColor = const Color(0xFFE8EDF3); // border
          textColor = const Color(0xFF64748B).withOpacity(0.5); // mutedForeground 50%
          icon = 'lock';
          iconColor = const Color(0xFF64748B);
        } else if (isSelected) {
          bgColor = theme.colorScheme.primary;
          borderColor = theme.colorScheme.primary;
          textColor = theme.colorScheme.onPrimary;
          icon = 'check-circle';
          iconColor = theme.colorScheme.onPrimary;
        } else {
          bgColor = theme.colorScheme.surface;
          borderColor = const Color(0xFFE8EDF3); // border
          textColor = theme.colorScheme.onSurface;
          icon = 'clock';
          iconColor = theme.colorScheme.primary;
        }

        return GestureDetector(
          onTap: isAvailable ? () => onSlotSelected?.call(i) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIcon(icon: icon, size: 14, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slot['time'] as String,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
