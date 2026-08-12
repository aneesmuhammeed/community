import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/models/booking_model.dart';
import 'package:uuid/uuid.dart';
class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<BookingModel>> getBookings(String residentId) async {
    final response = await _supabase
        .from('bookings')
        .select('*, facilities(name, capacity)')
        .eq('resident_id', residentId)
        .order('created_at', ascending: false);
    return (response as List).map((data) => BookingModel.fromJson(data)).toList();
  }

  Future<List<Map<String, dynamic>>> getFacilities(String societyId) async {
    final response = await _supabase
        .from('facilities')
        .select()
        .eq('society_id', societyId)
        .eq('is_active', true)
        .eq('status', 'available');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAvailableSlots(String societyId, String facilityId, DateTime selectedDate) async {
    final selectedDateStr = selectedDate.toIso8601String().split('T')[0];

    // 1. Determine day type (WEEKDAY, WEEKEND, HOLIDAY)
    String dayType = 'WEEKDAY';
    
    try {
      final holidayResponse = await _supabase
          .from('holidays')
          .select('id')
          .eq('society_id', societyId)
          .eq('date', selectedDateStr)
          .maybeSingle();
          
      if (holidayResponse != null) {
        dayType = 'HOLIDAY';
      } else if (selectedDate.weekday == DateTime.saturday || selectedDate.weekday == DateTime.sunday) {
        dayType = 'WEEKEND';
      }
    } catch (e) {
      // Fallback if holidays table is missing or query fails
      debugPrint('Warning: Failed to check holidays. Falling back to default day type. Error: $e');
      if (selectedDate.weekday == DateTime.saturday || selectedDate.weekday == DateTime.sunday) {
        dayType = 'WEEKEND';
      }
    }

    // 2. Fetch schedules for this day type
    List<Map<String, dynamic>> schedules = [];
    try {
      final scheduleResponse = await _supabase
          .from('facility_schedules')
          .select('start_time, end_time')
          .eq('facility_id', facilityId)
          .eq('day_type', dayType)
          .order('start_time');
      schedules = List<Map<String, dynamic>>.from(scheduleResponse);
    } catch (e) {
      debugPrint('Warning: Failed to fetch facility_schedules. Error: $e');
    }
    
    // Default fallback schedule if none defined or table missing (e.g., 9 AM to 6 PM, 1 hr slots)
    if (schedules.isEmpty) {
      for (int i = 9; i < 18; i++) {
        schedules.add({
          'start_time': '${i.toString().padLeft(2, '0')}:00:00',
          'end_time': '${(i + 1).toString().padLeft(2, '0')}:00:00',
        });
      }
    }

    // 3. Fetch existing bookings
    List<Map<String, dynamic>> existingBookings = [];
    try {
      final bookingResponse = await _supabase
          .from('bookings')
          .select('start_time, end_time, status')
          .eq('facility_id', facilityId)
          .eq('booking_date', selectedDateStr)
          .neq('status', 'cancelled');
      existingBookings = List<Map<String, dynamic>>.from(bookingResponse);
    } catch (e) {
      debugPrint('Warning: Failed to fetch bookings. Error: $e');
    }
    
    // 4. Fetch slot blocks/overrides
    List<Map<String, dynamic>> slotBlocks = [];
    try {
      final blocksResponse = await _supabase
          .from('facility_slot_blocks')
          .select('start_time, end_time')
          .eq('facility_id', facilityId)
          .eq('date', selectedDateStr);
      slotBlocks = List<Map<String, dynamic>>.from(blocksResponse);
    } catch (e) {
      debugPrint('Warning: Failed to fetch facility_slot_blocks. Error: $e');
    }

    List<Map<String, dynamic>> generatedSlots = [];
    
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && selectedDate.month == now.month && selectedDate.day == now.day;

    for (var schedule in schedules) {
      final startStr = schedule['start_time'].toString().substring(0, 5);
      final endStr = schedule['end_time'].toString().substring(0, 5);
      
      final startParts = startStr.split(':');
      final endParts = endStr.split(':');
      
      int startH = int.parse(startParts[0]);
      int startM = int.parse(startParts[1]);
      int endH = int.parse(endParts[0]);
      int endM = int.parse(endParts[1]);

      // Check if passed for today
      if (isToday) {
        if (startH < now.hour || (startH == now.hour && startM <= now.minute)) {
          continue; // Skip past slots
        }
      }

      // Check if blocked by admin
      bool isBlocked = slotBlocks.any((b) => b['start_time'].toString().startsWith(startStr));
      if (isBlocked) continue; // Don't even show blocked slots

      // Check if booked by user
      bool isBooked = existingBookings.any((b) => b['start_time'].toString().startsWith(startStr));

      final displayStart = _formatAmPm(startH, startM);
      final displayEnd = _formatAmPm(endH, endM);

      generatedSlots.add({
        'time': '$displayStart – $displayEnd',
        'start': '$startStr:00',
        'end': '$endStr:00',
        'available': !isBooked,
      });
    }
    
    return generatedSlots;
  }

  String _formatAmPm(int hour, int min) {
    final ampm = hour >= 12 ? 'PM' : 'AM';
    int h = hour % 12;
    if (h == 0) h = 12;
    return '$h:${min.toString().padLeft(2, '0')} $ampm';
  }

  Future<void> submitBooking({
    required String residentId,
    required String societyId,
    required String facilityId,
    required DateTime selectedDate,
    required Map<String, dynamic> slot,
    required double bookingFee,
  }) async {
    await _supabase.from('bookings').insert({
      'id': const Uuid().v4(),
      'resident_id': residentId,
      'facility_id': facilityId,
      'society_id': societyId,
      'booking_date': selectedDate.toIso8601String().split('T')[0],
      'start_time': slot['start'],
      'end_time': slot['end'],
      'status': 'pending',
      'booking_fee': bookingFee,
    });
  }

  Future<void> cancelBooking(String bookingId, String residentId) async {
    await _supabase
        .from('bookings')
        .update({'status': 'cancelled'})
        .eq('id', bookingId)
        .eq('resident_id', residentId);
  }
}
