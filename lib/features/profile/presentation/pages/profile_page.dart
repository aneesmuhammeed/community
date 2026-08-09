import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import 'family_members_page.dart';
import 'vehicles_page.dart';
import '../../../complaints/presentation/pages/my_complaints_page.dart';
import 'notifications_settings_page.dart';
import 'privacy_security_page.dart';
import 'help_support_page.dart';
import '../../data/profile_repository.dart';

class ProfilePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const ProfilePage({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  int _familyCount = 0;
  int _vehiclesCount = 0;
  int _openComplaints = 0;
  int _inProgressComplaints = 0;
  String _nextBookingInfo = 'No upcoming bookings';
  final _repository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _fetchProfileStats();
  }

  Future<void> _fetchProfileStats() async {
    try {
      final stats = await _repository.getProfileStats(currentUser.residentId);

      if (mounted) {
        setState(() {
          _familyCount = stats.familyCount;
          _vehiclesCount = stats.vehiclesCount;
          _openComplaints = stats.openComplaints;
          _inProgressComplaints = stats.inProgressComplaints;
          _nextBookingInfo = stats.nextBookingInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching profile stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSignOut() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign Out not connected to Auth yet.')),
    );
  }

  void _navigateToFamilyMembers() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FamilyMembersPage()),
    ).then((_) {
      _fetchProfileStats();
    });
  }

  void _navigateToVehicles() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VehiclesPage()),
    ).then((_) {
      _fetchProfileStats();
    });
  }

  void _navigateToComplaints() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MyComplaintsPage()),
    ).then((_) {
      _fetchProfileStats();
    });
  }

  void _navigateToNotifications() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsSettingsPage()));
  }

  void _navigateToPrivacySecurity() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const PrivacySecurityPage()));
  }

  void _navigateToHelpSupport() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelpSupportPage()));
  }

  void _navigateToBookings() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    String complaintsText = 'No active complaints';
    if (_openComplaints > 0 || _inProgressComplaints > 0) {
      final parts = <String>[];
      if (_openComplaints > 0) parts.add('$_openComplaints open');
      if (_inProgressComplaints > 0) parts.add('$_inProgressComplaints in progress');
      complaintsText = parts.join(' · ');
    }

    final menuSections = [
      {
        'title': 'My Home',
        'items': [
          {'icon': 'building-2', 'label': 'Apartment Details', 'sub': '${currentUser.block}, ${currentUser.apartment}'},
          {'icon': 'users', 'label': 'Family Members', 'sub': _isLoading ? 'Loading...' : '$_familyCount members registered', 'action': _navigateToFamilyMembers},
          {'icon': 'car', 'label': 'Registered Vehicles', 'sub': _isLoading ? 'Loading...' : '$_vehiclesCount vehicles', 'action': _navigateToVehicles},
        ],
      },
      {
        'title': 'Activity',
        'items': [
          {'icon': 'newspaper', 'label': 'Community Feed', 'sub': 'News, events & announcements', 'highlight': true},
          {'icon': 'message-circle', 'label': 'My Complaints', 'sub': _isLoading ? 'Loading...' : complaintsText, 'action': _navigateToComplaints},
          {'icon': 'calendar', 'label': 'My Bookings', 'sub': _isLoading ? 'Loading...' : _nextBookingInfo, 'action': _navigateToBookings},
        ],
      },
      {
        'title': 'Account',
        'items': [
          {'icon': 'bell', 'label': 'Notifications', 'sub': 'Manage alerts & reminders', 'action': _navigateToNotifications},
          {'icon': 'shield-check', 'label': 'Privacy & Security', 'sub': '', 'action': _navigateToPrivacySecurity},
          {'icon': 'help-circle', 'label': 'Help & Support', 'sub': 'Contact support or read FAQs', 'action': _navigateToHelpSupport},
          {'icon': 'log-out', 'label': 'Sign Out', 'sub': '', 'danger': true, 'action': _handleSignOut},
        ],
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.societyName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'Profile',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), // muted
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CustomIcon(
                          icon: 'bell',
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Profile Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EDF3)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E2850).withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    UserAvatar(
                      gender: currentUser.gender,
                      ageGroup: currentUser.ageGroup,
                      heritage: currentUser.heritage,
                      index: currentUser.avatarIndex,
                      size: 64,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${currentUser.block} · ${currentUser.apartment}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentUser.role,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ext.accentSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentUser.residentType,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF10B981), // accent
                                    fontWeight: FontWeight.w500,
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
              ),
            ),
          ),
          // Contact Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
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
                    _buildContactRow(context, 'phone', 'Phone', currentUser.phone, true),
                    _buildContactRow(context, 'mail', 'Email', currentUser.email, false),
                  ],
                ),
              ),
            ),
          ),
          // Menu Sections
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = menuSections[index];
                final title = section['title'] as String;
                final items = section['items'] as List<Map<String, dynamic>>;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
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
                          children: items.asMap().entries.map((entry) {
                            final i = entry.key;
                            final item = entry.value;
                            final isLast = i == items.length - 1;
                            
                            final isDanger = item['danger'] == true;
                            final isHighlight = item['highlight'] == true;

                            Color iconBgColor = const Color(0xFFF1F5F9); // muted
                            Color iconColor = const Color(0xFF64748B);
                            
                            if (isDanger) {
                              iconBgColor = const Color(0xFFFEE2E2); // danger-soft
                              iconColor = theme.colorScheme.error;
                            } else if (isHighlight) {
                              iconBgColor = theme.colorScheme.secondary;
                              iconColor = theme.colorScheme.primary;
                            }

                            return Column(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: item.containsKey('action') 
                                        ? () => (item['action'] as Function)() 
                                        : null,
                                    splashColor: item.containsKey('action') ? null : Colors.transparent,
                                    highlightColor: item.containsKey('action') ? null : Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: iconBgColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: CustomIcon(icon: item['icon'] as String, size: 16, color: iconColor),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['label'] as String,
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: isDanger ? theme.colorScheme.error : theme.colorScheme.onSurface,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                if ((item['sub'] as String).isNotEmpty) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    item['sub'] as String,
                                                    style: theme.textTheme.labelSmall?.copyWith(
                                                      color: const Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (!isDanger && item.containsKey('action'))
                                            const CustomIcon(icon: 'chevron-right', size: 16, color: Color(0xFF64748B)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  const Divider(height: 1, color: Color(0xFFE8EDF3)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: menuSections.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // padding for FAB/Navbar
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, String icon, String label, String value, bool withBorder) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: withBorder ? const Border(bottom: BorderSide(color: Color(0xFFE8EDF3))) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CustomIcon(icon: icon, size: 15, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
