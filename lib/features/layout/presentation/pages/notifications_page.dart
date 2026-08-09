import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';

class _Notification {
  final String id;
  final String title;
  final String body;
  final String time;
  final String type; // 'payment' | 'maintenance' | 'announcement' | 'visitor' | 'complaint'
  bool isRead;

  _Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<_Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      _Notification(
        id: '1',
        title: 'Maintenance Due Reminder',
        body: 'Your December 2024 maintenance bill of ₹3,500 is due on Dec 5. Pay now to avoid late fees.',
        time: '2 hours ago',
        type: 'payment',
      ),
      _Notification(
        id: '2',
        title: 'Visitor Arrived',
        body: 'Rahul Sharma has arrived at the gate. Your OTP is 4921.',
        time: '5 hours ago',
        type: 'visitor',
        isRead: true,
      ),
      _Notification(
        id: '3',
        title: 'Complaint Update',
        body: 'Your complaint #A1B2C3 (Water leaking) has been assigned to maintenance staff.',
        time: 'Yesterday',
        type: 'complaint',
        isRead: true,
      ),
      _Notification(
        id: '4',
        title: 'Society Announcement',
        body: 'Society AGM scheduled for Dec 15 at 6 PM in the Community Hall. Attendance is mandatory.',
        time: '2 days ago',
        type: 'announcement',
        isRead: true,
      ),
      _Notification(
        id: '5',
        title: 'Payment Received',
        body: 'Your November 2024 maintenance payment of ₹3,500 was successfully processed.',
        time: '5 days ago',
        type: 'payment',
        isRead: true,
      ),
      _Notification(
        id: '6',
        title: 'Lift Maintenance Notice',
        body: 'Lift B will be under maintenance on Dec 3rd (9 AM – 5 PM). Use Lift A during this time.',
        time: '1 week ago',
        type: 'maintenance',
        isRead: true,
      ),
    ];
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      _notifications.firstWhere((n) => n.id == id).isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 22, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIcon(icon: 'bell', size: 48, color: const Color(0xFFE8EDF3)),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: theme.textTheme.bodyLarge?.copyWith(color: const Color(0xFF64748B))),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE8EDF3), indent: 20, endIndent: 20),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return _NotificationTile(
                  notification: n,
                  theme: theme,
                  ext: ext,
                  onTap: () => _markRead(n.id),
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _Notification notification;
  final ThemeData theme;
  final AppThemeExtension ext;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.theme,
    required this.ext,
    required this.onTap,
  });

  _TypeStyle _getTypeStyle() {
    switch (notification.type) {
      case 'payment':
        return _TypeStyle(icon: 'indian-rupee', bg: ext.accentSoft, color: const Color(0xFF10B981));
      case 'visitor':
        return _TypeStyle(icon: 'user-check', bg: theme.colorScheme.secondary, color: theme.colorScheme.primary);
      case 'complaint':
        return _TypeStyle(icon: 'wrench', bg: ext.warningSoft, color: ext.warningForeground);
      case 'announcement':
        return _TypeStyle(icon: 'megaphone', bg: ext.aiSoft, color: ext.ai);
      case 'maintenance':
      default:
        return _TypeStyle(icon: 'wrench', bg: const Color(0xFFF1F5F9), color: const Color(0xFF64748B));
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getTypeStyle();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: notification.isRead ? Colors.transparent : theme.colorScheme.primary.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(10)),
              child: Center(child: CustomIcon(icon: style.icon, size: 18, color: style.color)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.time,
                    style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeStyle {
  final String icon;
  final Color bg;
  final Color color;
  const _TypeStyle({required this.icon, required this.bg, required this.color});
}
