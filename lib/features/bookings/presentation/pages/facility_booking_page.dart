import '../../../../core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../widgets/mini_calendar.dart';
import '../widgets/facility_card.dart';
import '../widgets/time_slot_grid.dart';
import '../widgets/booking_confirmation_card.dart';
import '../widgets/my_booking_card.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/booking_repository.dart';

class FacilityBookingPage extends ConsumerStatefulWidget {
  const FacilityBookingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FacilityBookingPage> createState() => _FacilityBookingPageState();
}

class _FacilityBookingPageState extends ConsumerState<FacilityBookingPage> {
  late Future<List<BookingModel>> _bookingsFuture;
  late Future<List<Map<String, dynamic>>> _facilitiesFuture;

  String? _selectedFacilityId;
  int _selectedTimeIndex = -1;
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> _dynamicSlots = [];
  bool _isLoadingSlots = false;
  final _repository = BookingRepository();

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
    return _repository.getBookings(ref.read(userProvider)!.residentId);
  }

  Future<List<Map<String, dynamic>>> _fetchFacilities() async {
    return _repository.getFacilities(ref.read(userProvider)!.societyId);
  }

  Future<void> _onFacilitySelected(String id) async {
    setState(() {
      _selectedFacilityId = id;
      _selectedTimeIndex = -1;
      _isLoadingSlots = true;
    });
    await _loadSlotsForSelectedDate();
  }

  Future<void> _loadSlotsForSelectedDate() async {
    if (_selectedFacilityId == null) return;
    
    setState(() {
      _isLoadingSlots = true;
      _selectedTimeIndex = -1;
      _dynamicSlots = [];
    });

    try {
      final slots = await _repository.getAvailableSlots(
        ref.read(userProvider)!.societyId,
        _selectedFacilityId!,
        _selectedDate,
      );
      
      if (mounted) {
        setState(() {
          _dynamicSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      print('Error loading slots: $e');
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedFacilityId == null || _selectedTimeIndex == -1) return;

    // Guard: index out of bounds (slots may have changed)
    if (_selectedTimeIndex >= _dynamicSlots.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected slot is no longer available. Please pick again.')));
        setState(() => _selectedTimeIndex = -1);
      }
      return;
    }

    // Guard: prevent booking past dates if user left the page open overnight
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    if (_selectedDate.isBefore(todayDate)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot book a past date. Please select a future date.')));
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final slot = _dynamicSlots[_selectedTimeIndex];
      
      // Find selected facility to get booking fee
      final facilityList = await _facilitiesFuture;
      final selectedFacility = facilityList.firstWhere((f) => f['id'] == _selectedFacilityId);
      final bookingFee = (selectedFacility['booking_fee'] as num?)?.toDouble() ?? 0.0;
      
      await _repository.submitBooking(
        residentId: ref.read(userProvider)!.residentId,
        societyId: ref.read(userProvider)!.societyId,
        facilityId: _selectedFacilityId!,
        selectedDate: _selectedDate,
        slot: slot,
        bookingFee: bookingFee,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facility booked successfully!')));
        setState(() {
          _selectedFacilityId = null;
          _selectedTimeIndex = -1;
          _dynamicSlots = [];
        });
        _fetchData();
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('23505') || e.toString().contains('unique_active_booking') || e.toString().contains('no_overlapping_bookings')) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorry, this slot was just booked by someone else!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
        _loadSlotsForSelectedDate();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await _repository.cancelBooking(bookingId, ref.read(userProvider)!.residentId);
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled successfully')));
        _fetchData(); // Refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelling booking: $e')));
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
                          ref.watch(userProvider)!.societyName,
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
                    final isSelected = chip == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = chip;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : const Color(0xFFE8EDF3),
                          ),
                        ),
                        child: Text(
                          chip,
                          style: theme.textTheme.labelMedium?.copyWith(
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
                  MiniCalendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _loadSlotsForSelectedDate();
                    },
                  ),
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
                      final filteredFacilities = facilities.where((f) => _selectedCategory == 'All' || f['name'] == _selectedCategory).toList();

                      if (filteredFacilities.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No facilities found for this category.'),
                          ),
                        );
                      }

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.70,
                        ),
                        itemCount: filteredFacilities.length,
                        itemBuilder: (context, index) {
                          final facility = filteredFacilities[index];
                          final id = facility['id'] as String;
                          return FacilityCard(
                            name: facility['name'] as String,
                            status: facility['status'] as String,
                            capacity: facility['capacity'] as int? ?? 0,
                            hours: facility['operating_hours']?.toString() ?? '',
                            bookingFee: (facility['booking_fee'] as num?)?.toDouble() ?? 0.0,
                            icon: 'building', // Dummy icon since db lacks it
                            isSelected: _selectedFacilityId == id,
                            onTap: () => _onFacilitySelected(id),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedFacilityId == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Please select a facility first'),
                      ),
                    )
                  else if (_isLoadingSlots)
                    const Center(child: CircularProgressIndicator())
                  else if (_dynamicSlots.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('No slots available today'),
                      ),
                    )
                  else
                    TimeSlotGrid(
                      slots: _dynamicSlots,
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
                      final booking = bookings[index];
                      
                      // Only compute canCancel for active bookings
                      bool canCancel = false;
                      if (booking.status != 'cancelled') {
                        canCancel = true;
                        try {
                          if (booking.rawDate.isNotEmpty && booking.rawStartTime.isNotEmpty) {
                            final dateParts = booking.rawDate.split('-');
                            final timeParts = booking.rawStartTime.split(':');
                            if (dateParts.length >= 3 && timeParts.length >= 2) {
                              final bookingDateTime = DateTime(
                                int.parse(dateParts[0]),
                                int.parse(dateParts[1]),
                                int.parse(dateParts[2]),
                                int.parse(timeParts[0]),
                                int.parse(timeParts[1]),
                              );
                              final difference = bookingDateTime.difference(DateTime.now());
                              canCancel = difference.inHours >= 24;
                            }
                          }
                        } catch (_) {
                          canCancel = true; // Default to allowing cancel if parsing fails
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MyBookingCard(
                          facility: booking.facility,
                          date: booking.date,
                          time: booking.time,
                          status: booking.status,
                          icon: booking.icon,
                          canCancel: canCancel,
                          onCancel: () {
                            if (!canCancel) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookings cannot be cancelled within 24 hours of the start time.')));
                              return;
                            }
                            _cancelBooking(booking.id);
                          },
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
