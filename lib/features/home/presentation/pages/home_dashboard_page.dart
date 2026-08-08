import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/app_spacing.dart';
import '../widgets/home_header.dart';
import '../widgets/community_info_banner.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/visitor_alert_card.dart';
import '../widgets/announcement_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/visitor_model.dart';
import '../../../../core/models/announcement_model.dart';

class HomeDashboardPage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeDashboardPage({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  late Future<List<VisitorModel>> _visitorsFuture;
  late Future<List<AnnouncementModel>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _visitorsFuture = _fetchVisitors();
    _announcementsFuture = _fetchAnnouncements();
  }

  Future<List<VisitorModel>> _fetchVisitors() async {
    final response = await Supabase.instance.client
        .from('visitors')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((data) => VisitorModel.fromJson(data)).toList();
  }

  Future<List<AnnouncementModel>> _fetchAnnouncements() async {
    final response = await Supabase.instance.client
        .from('announcements')
        .select()
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return (response as List).map((data) => AnnouncementModel.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverToBoxAdapter(
            child: HomeHeader(
              greeting: 'Good Afternoon 👋',
              user: currentUser,
              hasNotification: true,
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: CommunityInfoBanner(
            societyName: currentUser.societyName,
            unitDetails: '${currentUser.block}, ${currentUser.apartment}',
          ),
        ),

        // Quick Actions
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuickActionButton(
                      icon: 'user-check', 
                      label: 'Visitor\nPass', 
                      colorVariant: 'blue',
                      onTap: () => widget.onNavigate?.call(1),
                    ),
                    QuickActionButton(
                      icon: 'message-square', 
                      label: 'Complaint', 
                      colorVariant: 'green',
                      onTap: () => widget.onNavigate?.call(2),
                    ),
                    QuickActionButton(
                      icon: 'calendar-check', 
                      label: 'Bookings', 
                      colorVariant: 'amber',
                      onTap: () => widget.onNavigate?.call(4),
                    ),
                    QuickActionButton(
                      icon: 'message-square', 
                      label: 'Community', 
                      colorVariant: 'purple',
                      onTap: () {}, // Community doesn't have a direct tab yet
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

        // Visitor Alerts
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Visitors Today',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'See all',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: FutureBuilder<List<VisitorModel>>(
            future: _visitorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Text('Error loading visitors: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Text('No visitors today.'));
              }

              final visitors = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final visitor = visitors[index];
                    return VisitorCard(
                      name: visitor.name,
                      time: visitor.time,
                      purpose: visitor.purpose,
                      status: visitor.status,
                      gender: visitor.gender,
                      heritage: visitor.heritage,
                      index: visitor.avatarIndex,
                    );
                  },
                  childCount: visitors.length,
                ),
              );
            },
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

        // Announcements
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Announcements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View all',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: FutureBuilder<List<AnnouncementModel>>(
            future: _announcementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Text('Error loading announcements: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Text('No announcements.'));
              }

              final announcements = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final announcement = announcements[index];
                    return AnnouncementCard(
                      title: announcement.title,
                      body: announcement.body,
                      time: _formatDate(announcement.publishAt),
                      tag: announcement.tag,
                      tagVariant: announcement.isPinned ? 'warning' : 'info',
                      icon: announcement.icon,
                    );
                  },
                  childCount: announcements.length,
                ),
              );
            },
          ),
        ),
        
        // Bottom padding to ensure last item is visible above FAB/NavBar
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final difference = DateTime.now().difference(date);
      if (difference.inDays > 0) return '${difference.inDays}d ago';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}
