import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class MiniCalendar extends StatelessWidget {
  const MiniCalendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    // December 2024 states: 1-10 past, 14 selected, some booked, rest avail
    const dateStates = {
      1: 'past', 2: 'past', 3: 'past', 4: 'past', 5: 'past',
      6: 'past', 7: 'past', 8: 'past', 9: 'past', 10: 'past',
      11: 'avail', 12: 'booked', 13: 'avail', 14: 'selected', 15: 'avail',
      16: 'booked', 17: 'avail', 18: 'avail', 19: 'booked', 20: 'avail',
      21: 'avail', 22: 'avail', 23: 'booked', 24: 'avail', 25: 'booked',
      26: 'avail', 27: 'avail', 28: 'booked', 29: 'avail', 30: 'avail',
      31: 'avail',
    };

    final cells = List.generate(31, (index) => index + 1);

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
      child: Column(
        children: [
          // Month header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // muted
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: CustomIcon(icon: 'chevron-left', size: 16, color: Color(0xFF64748B)),
                ),
              ),
              Text(
                'December 2024',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // muted
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: CustomIcon(icon: 'chevron-right', size: 16, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Dates grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: cells.length,
            itemBuilder: (context, i) {
              final day = cells[i];
              final state = dateStates[day] ?? 'avail';

              Color bgColor = Colors.transparent;
              Color textColor = theme.colorScheme.onSurface;
              FontWeight weight = FontWeight.w400;

              if (state == 'past') {
                textColor = const Color(0xFF64748B).withOpacity(0.4);
              } else if (state == 'avail') {
                bgColor = const Color(0xFFF0FDF4); // green-50
                textColor = const Color(0xFF15803D); // green-700
              } else if (state == 'booked') {
                bgColor = const Color(0xFFFEE2E2); // dangerSoft
                textColor = theme.colorScheme.error;
              } else if (state == 'selected') {
                bgColor = theme.colorScheme.primary;
                textColor = theme.colorScheme.onPrimary;
                weight = FontWeight.bold;
              }

              return Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                        fontWeight: weight,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE8EDF3)),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Selected', theme.colorScheme.primary),
              const SizedBox(width: 16),
              _buildLegendItem('Booked', theme.colorScheme.error),
              const SizedBox(width: 16),
              _buildLegendItem('Available', const Color(0xFF22C55E)), // green-500
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
