import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class MiniCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const MiniCalendar({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    final emptyCells = firstWeekday == 7 ? 0 : firstWeekday; // Dart weekday: 1=Mon, 7=Sun

    final today = DateTime.now();

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
              GestureDetector(
                onTap: _prevMonth,
                child: Container(
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
              ),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: Container(
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
            itemCount: emptyCells + daysInMonth,
            itemBuilder: (context, i) {
              if (i < emptyCells) return const SizedBox();
              
              final day = i - emptyCells + 1;
              final cellDate = DateTime(_currentMonth.year, _currentMonth.month, day);
              
              final isSelected = cellDate.year == widget.selectedDate.year &&
                                 cellDate.month == widget.selectedDate.month &&
                                 cellDate.day == widget.selectedDate.day;
              
              final isPast = cellDate.isBefore(DateTime(today.year, today.month, today.day));

              // We default future non-selected dates to 'available' since full-month slot computation is very heavy.
              String state = 'avail';
              if (isPast) state = 'past';
              if (isSelected) state = 'selected';

              Color bgColor = Colors.transparent;
              Color textColor = theme.colorScheme.onSurface;
              FontWeight weight = FontWeight.w400;

              if (state == 'past') {
                textColor = const Color(0xFF64748B).withOpacity(0.4);
              } else if (state == 'avail') {
                bgColor = const Color(0xFFF0FDF4); // green-50
                textColor = const Color(0xFF15803D); // green-700
              } else if (state == 'selected') {
                bgColor = theme.colorScheme.primary;
                textColor = theme.colorScheme.onPrimary;
                weight = FontWeight.bold;
              }

              return GestureDetector(
                onTap: isPast ? null : () {
                  widget.onDateSelected(cellDate);
                },
                child: Center(
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
              _buildLegendItem('Available', const Color(0xFF22C55E)), // green-500
              const SizedBox(width: 16),
              _buildLegendItem('Past', const Color(0xFF94A3B8)), // slate-400
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
