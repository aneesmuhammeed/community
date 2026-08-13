import '../../../../core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/app_spacing.dart';
import '../widgets/home_header.dart';
import '../widgets/community_info_banner.dart';
import '../widgets/quick_action_button.dart';
import '../../../visitors/presentation/widgets/guest_invite_card.dart';
import '../widgets/announcement_card.dart';
import '../widgets/poll_card.dart';
import '../../data/home_repository.dart';
import '../../../../core/models/guest_invite_model.dart';
import '../../../../core/models/announcement_model.dart';
import '../../../../core/models/poll_model.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  final Function(int)? onNavigate;

  const HomeDashboardPage({super.key, this.onNavigate});

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  late Future<List<GuestInviteModel>> _visitorsFuture;
  late Future<List<AnnouncementModel>> _announcementsFuture;
  late Future<List<PollModel>> _pollsFuture;
  late Future<List<String>> _votedPollIdsFuture;
  final HomeRepository _repository = HomeRepository();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback because we need to read from the provider in init, but `ref` might not be safe to watch in initState before build for the first time, though read is fine. However, since the state might change, these futures might not re-fetch. We'll stick to how it was doing it before (using watch which was technically incorrect in initState but the script blindly replaced it). Actually, `ref.read` is safe in initState.
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visitorsFuture = _repository.getVisitors(ref.read(userProvider)!.residentId);
    _announcementsFuture = _repository.getAnnouncements(ref.read(userProvider)!.societyId);
    _refreshPolls();
  }

  void _refreshPolls() {
    final societyId = ref.read(userProvider)!.societyId;
    final residentId = ref.read(userProvider)!.residentId;
    setState(() {
      _pollsFuture = _repository.getPolls(societyId);
      _votedPollIdsFuture = _repository.getVotedPollIds(residentId);
    });
  }

  Future<void> _triggerSOS() async {
    final residentId = ref.read(userProvider)!.residentId;
    
    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 SOS Alert Sent to Security!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );

    try {
      await Supabase.instance.client.from('sos_alerts').insert({
        'resident_id': residentId,
        'status': 'active',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS: $e'), backgroundColor: Colors.red[900]),
        );
      }
    }
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
              user: ref.watch(userProvider)!,
              hasNotification: true,
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: CommunityInfoBanner(
            societyName: ref.watch(userProvider)!.societyName,
            unitDetails: '${ref.watch(userProvider)!.block}, ${ref.watch(userProvider)!.apartment}',
          ),
        ),

        // Quick Actions - Refactored to Wrap for responsiveness
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _triggerSOS,
                  icon: const Icon(Icons.warning_amber_rounded, size: 28),
                  label: const Text('EMERGENCY SOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
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
                      onTap: () {}, 
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
                Text('Recent Invites', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () => widget.onNavigate?.call(1),
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
          sliver: FutureBuilder<List<GuestInviteModel>>(
            future: _visitorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                );
              } else if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Failed to load visitors. Please try again.', style: TextStyle(color: Colors.red))),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Text('No recent invites.'));
              }

              final visitors = snapshot.data!.take(5).toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final visitor = visitors[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      // Ideally, refactor GuestInviteCard to accept GuestInviteModel directly
                      child: GuestInviteCard(
                        id: visitor.id,
                        name: visitor.name,
                        relation: visitor.relation,
                        date: visitor.date,
                        method: visitor.method,
                        code: visitor.code,
                        status: visitor.status,
                        gender: visitor.gender,
                        heritage: visitor.heritage,
                        index: visitor.avatarIndex,
                        validUntil: visitor.validUntil,
                        otpValue: visitor.otpValue,
                        unitNumber: ref.watch(userProvider)!.apartment,
                      ),
                    );
                  },
                  childCount: visitors.length,
                ),
              );
            },
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

        // Announcements Header
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Text('Announcements', style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Announcements List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: FutureBuilder<List<AnnouncementModel>>(
            future: _announcementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                );
              } else if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Failed to load announcements.', style: TextStyle(color: Colors.red))),
                );
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
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

        // Polls Header
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: SliverToBoxAdapter(
            child: Text('Active Polls', style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Polls List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: FutureBuilder(
            future: Future.wait([_pollsFuture, _votedPollIdsFuture]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                );
              } else if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Failed to load polls.', style: TextStyle(color: Colors.red))),
                );
              }

              final polls = snapshot.data![0] as List<PollModel>;
              final votedIds = snapshot.data![1] as List<String>;

              if (polls.isEmpty) {
                return const SliverToBoxAdapter(child: Text('No active polls.'));
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final poll = polls[index];
                    return PollCard(
                      poll: poll,
                      hasVoted: votedIds.contains(poll.id),
                      onVoteCast: _refreshPolls,
                    );
                  },
                  childCount: polls.length,
                ),
              );
            },
          ),
        ),
        
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
