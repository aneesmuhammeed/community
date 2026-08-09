import 'package:flutter/material.dart';
import 'package:community_hub/features/home/presentation/pages/home_dashboard_page.dart';
import 'package:community_hub/features/visitors/presentation/pages/visitor_invite_page.dart';
import 'package:community_hub/features/complaints/presentation/pages/raise_complaint_page.dart';
import 'package:community_hub/features/maintenance/presentation/pages/maintenance_and_billing_page.dart';
import 'package:community_hub/features/bookings/presentation/pages/facility_booking_page.dart';
import 'package:community_hub/features/profile/presentation/pages/profile_page.dart';
import '../widgets/ai_chat_fab.dart';
import '../widgets/bottom_tab_bar.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({Key? key}) : super(key: key);

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeDashboardPage(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const VisitorInvitePage(),
      const RaiseComplaintPage(),
      const MaintenanceAndBillingPage(),
      const FacilityBookingPage(),
      ProfilePage(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomTabBar(
        activeTab: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: const AIChatFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
