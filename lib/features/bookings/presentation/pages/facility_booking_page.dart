import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../widgets/mini_calendar.dart';
import '../widgets/facility_card.dart';
import '../widgets/time_slot_grid.dart';
import '../widgets/booking_confirmation_card.dart';
import '../widgets/my_booking_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class FacilityBookingPage extends StatefulWidget {
  const FacilityBookingPage({Key? key}) : super(key: key);

  @override
  State<FacilityBookingPage> createState() => _FacilityBookingPageState();
}

class _FacilityBookingPageState extends State<FacilityBookingPage> {
  late Future<List<BookingModel>> _bookingsFuture;
  late Future<List<Map<String, dynamic>>> _facilitiesFuture;

  String? _selectedFacilityId;
  int _selectedTimeIndex = -1;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _slots = [
    {'time': '8:00 AM – 10:00 AM', 'start': '08:00:00', 'end': '10:00:00'},
    {'time': '10:00 AM – 12:00 PM', 'start': '10:00:00', 'end': '12:00:00'},
    {'time': '12:00 PM – 2:00 PM', 'start': '12:00:00', 'end': '14:00:00'},
    {'time': '2:00 PM – 4:00 PM', 'start': '14:00:00', 'end': '16:00:00'},
    {'time': '4:00 PM – 6:00 PM', 'start': '16:00:00', 'end': '18:00:00'},
    {'time': '6:00 PM – 9:00 PM', 'start': '18:00:00', 'end': '21:00:00'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _bookingsFuture = _fetchBookings();
      _facilitiesFuture = _fetchFacilities();
    });
  }

  Future<List<BookingModel>> _fetchBookings() async {
    final response = await Supabase.instance.client
        .from('bookings')
        .select('*, facilities(name, capacity)') // Note: icon is not in schema
        .eq('resident_id', currentUser.residentId)
        .order('created_at', ascending: false);
    return (response as List).map((data) => BookingModel.fromJson(data)).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchFacilities() async {
    final response = await Supabase.instance.client
        .from('facilities')
        .select()
        .eq('society_id', currentUser.societyId)
        .eq('is_active', true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _submitBooking() async {
    if (_selectedFacilityId == null || _selectedTimeIndex == -1) return;

    setState(() => _isSubmitting = true);

    try {
      final slot = _slots[_selectedTimeIndex];
      // Note: hardcoding resident_id and society_id to match dummy data
      await Supabase.instance.client.from('bookings').insert({
        'id': const Uuid().v4(),
        'resident_id': currentUser.residentId,
        'facility_id': _selectedFacilityId,
        'society_id': currentUser.societyId,
        'booking_date': DateTime.now().toIso8601String().split('T')[0], // today
        'start_time': slot['start'],
        'end_time': slot['end'],
        'status': 'confirmed',
        'booking_fee': 0.0, // Should be fetched from facility, but just 0 for dummy
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facility booked successfully!')));
        setState(() {
          _selectedFacilityId = null;
          _selectedTimeIndex = -1;
        });
        _fetchData(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final facilityChips = ['All', 'Clubhouse', 'Gym', 'Party Hall', 'Tennis Court', 'Pool'];

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
                          'Facility Booking',
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
          // Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA), // input
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE8EDF3)), // border
                ),
                child: Row(
                  children: [
                    const CustomIcon(icon: 'search', size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search facilities…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const CustomIcon(icon: 'sliders-horizontal', size: 15, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          // Filter Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: facilityChips.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final chip = facilityChips[index];
                    final isSelected = index == 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : const Color(0xFFE8EDF3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chip,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected ? theme.colorScheme.onPrimary : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Calendar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const MiniCalendar(), // Mockup calendar for now
                ],
              ),
            ),
          ),
          // Available Facilities
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Facilities',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _facilitiesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading facilities: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No facilities found.');
                      }

                      final facilities = snapshot.data!;
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.73,
                        ),
                        itemCount: facilities.length,
                        itemBuilder: (context, index) {
                          final facility = facilities[index];
                          final id = facility['id'] as String;
                          return FacilityCard(
                            name: facility['name'] as String,
                            status: facility['status'] as String,
                            capacity: facility['capacity'] as int,
                            hours: facility['operating_hours'] as String,
                            icon: 'building', // Dummy icon since db lacks it
                            isSelected: _selectedFacilityId == id,
                            onTap: () {
                              setState(() {
                                _selectedFacilityId = id;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Time Slot Selection
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Time Slot',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Today', // Dummy
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TimeSlotGrid(
                    selectedIndex: _selectedTimeIndex,
                    onSlotSelected: (index) {
                      setState(() {
                        _selectedTimeIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Confirm Action
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedFacilityId != null && _selectedTimeIndex != -1 && !_isSubmitting)
                      ? _submitBooking
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          // Divider
          const SliverToBoxAdapter(
            child: Divider(color: Color(0xFFE8EDF3), height: 1),
          ),
          // My Bookings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Bookings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'History',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bookings List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: FutureBuilder<List<BookingModel>>(
              future: _bookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: Center(child: Text('Error loading bookings: ${snapshot.error}')));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Text('No past bookings.')));
                }

                final bookings = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MyBookingCard(
                          facility: bookings[index].facility,
                          date: bookings[index].date,
                          time: bookings[index].time,
                          status: bookings[index].status,
                          icon: bookings[index].icon,
                        ),
                      );
                    },
                    childCount: bookings.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
