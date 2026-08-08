import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_spacing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

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
  final String validUntil;
  final String otpValue;
  final String unitNumber;
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
    this.validUntil = '',
    this.otpValue = '',
    this.unitNumber = '',
    this.onRevoke,
  }) : super(key: key);

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final timeStr = '$hour:$minute $ampm';

      if (isToday) {
        return 'Today, $timeStr';
      } else {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[dt.month - 1]} ${dt.day}, $timeStr';
      }
    } catch (_) {
      return isoString;
    }
  }

  String _getPendingTime(String validUntilStr) {
    if (validUntilStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(validUntilStr).toLocal();
      final now = DateTime.now();
      final diff = dt.difference(now);
      if (diff.isNegative) return 'Expired';
      if (diff.inHours > 0) return 'Expires in ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
      if (diff.inMinutes > 0) return 'Expires in ${diff.inMinutes}m';
      return 'Expires soon';
    } catch (_) {
      return '';
    }
  }

  void _shareInvite() {
    final message = 'Hi $name! Here is your CommunityHub visitor pass code: $code\n${otpValue.isNotEmpty ? 'Your OTP is: $otpValue\n' : ''}Please show this at the gate.';
    Share.share(message);
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    final message = 'Hi $name! Here is your CommunityHub visitor pass code: $code\n${otpValue.isNotEmpty ? 'Your OTP is: $otpValue\n' : ''}Please show this at the gate.';
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(message)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp is not installed')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
      }
    }
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pass code copied to clipboard')));
  }

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
      case 'cancelled':
        statusBgColor = const Color(0xFFFEE2E2); // dangerSoft
        statusTextColor = const Color(0xFFEF4444); // danger
        statusLabel = status == 'denied' ? 'Denied' : status == 'cancelled' ? 'Cancelled' : 'Expired';
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

    return InkWell(
      onTap: () => _showSummary(context, theme, statusBgColor, statusTextColor, statusLabel),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
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
                  '$relation · ${_formatDate(date)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B), // muted-foreground
                  ),
                ),
                if ((status == 'active' || status == 'pending') && validUntil.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getPendingTime(validUntil),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                if (otpValue.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomIcon(
                        icon: 'hash',
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'OTP : $otpValue',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
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
      ),
    );
  }

  void _showSummary(BuildContext context, ThemeData theme, Color statusBgColor, Color statusTextColor, String statusLabel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              // QR Code Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // dark background like in screenshot
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 180.0,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(name.isNotEmpty ? name : 'Guest', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text('Invited to ${unitNumber.isNotEmpty ? unitNumber : relation}', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B))),
              const SizedBox(height: 16),
              
              // Pass ID Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF), // blue-100
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomIcon(icon: 'hash', size: 16, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Text(code, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF3B82F6), fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Expires info
              if (validUntil.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomIcon(icon: 'clock', size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text(_getPendingTime(validUntil), style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B))),
                  ],
                ),
              
              const SizedBox(height: 32),
              
              // Share section
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Share invite via', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B))),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _shareInvite,
                      icon: const CustomIcon(icon: 'share-2', size: 18, color: Colors.white),
                      label: const Text('Share'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), // blue-600
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _shareWhatsApp(context),
                      icon: const CustomIcon(icon: 'message-circle', size: 18, color: Color(0xFF2563EB)),
                      label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF2563EB))),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDBEAFE), // blue-100
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // slate-100
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _copyCode(context),
                      icon: const CustomIcon(icon: 'copy', size: 20, color: Color(0xFF475569)),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
              
              // OTP Section
              if (otpValue.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE), // blue-100
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('One-Time Password (Flat $unitNumber)', style: theme.textTheme.titleSmall?.copyWith(color: const Color(0xFF1E40AF))), // blue-800
                          if (validUntil.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBFDBFE), // blue-200
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  const CustomIcon(icon: 'clock', size: 12, color: Color(0xFF1E40AF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getPendingTime(validUntil).replaceAll('Expires in ', '').replaceAll('Expires ', ''), 
                                    style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF1E40AF))
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            otpValue.split('').join('   '),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: const Color(0xFF2563EB), // blue-600
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSummaryRow(ThemeData theme, String label, String value, String icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
          child: CustomIcon(icon: icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600])),
            Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
