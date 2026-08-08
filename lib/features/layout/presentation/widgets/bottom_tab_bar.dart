import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';

class BottomTabBar extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int>? onTabSelected;

  const BottomTabBar({
    Key? key,
    this.activeTab = 0,
    this.onTabSelected,
  }) : super(key: key);

  static const List<Map<String, String>> tabs = [
    {'icon': 'home', 'label': 'Home', 'id': 'home'},
    {'icon': 'shield-check', 'label': 'Visitors', 'id': 'visitors'},
    {'icon': 'message-circle', 'label': 'Complaints', 'id': 'complaints'},
    {'icon': 'wrench', 'label': 'Maintenance', 'id': 'maintenance'},
    {'icon': 'calendar', 'label': 'Bookings', 'id': 'bookings'},
    {'icon': 'user-circle', 'label': 'Profile', 'id': 'profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2850).withOpacity(0.06),
            offset: const Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = index == activeTab;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    onTabSelected?.call(index);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? colorScheme.secondary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIcon(
                          icon: tab['icon']!,
                          size: 22,
                          color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tab['label']!,
                        style: textTheme.labelLarge?.copyWith(
                          color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
