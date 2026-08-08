import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';

class GuestInviteCard extends StatelessWidget {
  final String id;
  final String name;
  final String relation;
  final String date;
  final String method;
  final String code;
  final String status;
  final String gender;
  final String heritage;
  final int index;
  final VoidCallback? onRevoke;

  const GuestInviteCard({
    Key? key,
    this.id = '',
    this.name = 'Rahul Gupta',
    this.relation = 'Friend',
    this.date = 'Today, 3:00 PM',
    this.method = 'qr',
    this.code = 'VIS-8472',
    this.status = 'active',
    this.gender = 'male',
    this.heritage = 'South Asian',
    this.index = 0,
    this.onRevoke,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    switch (status) {
      case 'used':
        statusBgColor = const Color(0xFFF1F5F9); // muted
        statusTextColor = const Color(0xFF64748B); // mutedForeground
        statusLabel = 'Used';
        break;
      case 'denied':
      case 'expired':
        statusBgColor = const Color(0xFFFEE2E2); // dangerSoft
        statusTextColor = const Color(0xFFEF4444); // danger
        statusLabel = status == 'denied' ? 'Denied' : 'Expired';
        break;
      case 'active':
      case 'pending':
        statusBgColor = ext.warningSoft;
        statusTextColor = const Color(0xFFF59E0B); // warning
        statusLabel = 'Pending';
        break;
      case 'entered':
        statusBgColor = const Color(0xFFDBEAFE); // blue soft
        statusTextColor = const Color(0xFF3B82F6); // blue
        statusLabel = 'Arrived';
        break;
      case 'approved':
      default:
        statusBgColor = ext.accentSoft;
        statusTextColor = const Color(0xFF10B981); // accent
        statusLabel = status == 'approved' ? 'Approved' : 'Active';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFE8EDF3)), // border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(
            gender: gender,
            heritage: heritage,
            index: index,
            size: 40.0,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$relation · $date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B), // muted-foreground
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CustomIcon(
                      icon: method == 'qr' ? 'qr-code' : 'key-round',
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      code,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                if (onRevoke != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onRevoke,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFEE2E2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Cancel Invite', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
