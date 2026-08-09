import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/family_member_model.dart';
import '../../../../core/models/vehicle_model.dart';

class ProfileStats {
  final int familyCount;
  final int vehiclesCount;
  final int openComplaints;
  final int inProgressComplaints;
  final String nextBookingInfo;

  ProfileStats({
    required this.familyCount,
    required this.vehiclesCount,
    required this.openComplaints,
    required this.inProgressComplaints,
    required this.nextBookingInfo,
  });
}

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  // --- Family Members ---
  Future<List<FamilyMemberModel>> getFamilyMembers(String residentId) async {
    final res = await _supabase
        .from('family_members')
        .select()
        .eq('resident_id', residentId)
        .order('created_at', ascending: true);
        
    return (res as List).map((data) => FamilyMemberModel.fromJson(data)).toList();
  }

  Future<void> deleteFamilyMember(String id) async {
    await _supabase.from('family_members').delete().eq('id', id);
  }

  // --- Vehicles ---
  Future<List<VehicleModel>> getVehicles(String residentId) async {
    final res = await _supabase
        .from('vehicles')
        .select()
        .eq('resident_id', residentId)
        .eq('is_active', true)
        .order('created_at', ascending: true);

    return (res as List).map((data) => VehicleModel.fromJson(data)).toList();
  }

  Future<void> deleteVehicle(String id) async {
    await _supabase.from('vehicles').delete().eq('id', id);
  }

  // --- Notification Settings ---
  Future<Map<String, dynamic>?> getNotificationSettings(String residentId) async {
    return await _supabase
        .from('user_notification_settings')
        .select()
        .eq('resident_id', residentId)
        .maybeSingle();
  }

  Future<void> createDefaultNotificationSettings(String residentId) async {
    await _supabase.from('user_notification_settings').insert({
      'resident_id': residentId,
      'global_push_enabled': true,
      'announcements_enabled': true,
    });
  }

  Future<void> updateNotificationSetting(String residentId, String key, bool value) async {
    await _supabase
        .from('user_notification_settings')
        .update({key: value})
        .eq('resident_id', residentId);
  }

  // --- Profile Stats ---
  Future<ProfileStats> getProfileStats(String residentId) async {
    final results = await Future.wait<dynamic>([
      _supabase.from('family_members').select('id').eq('resident_id', residentId).count(CountOption.exact),
      _supabase.from('vehicles').select('id').eq('resident_id', residentId).eq('is_active', true).count(CountOption.exact),
      _supabase.from('complaints').select('status').eq('resident_id', residentId),
      _supabase.from('bookings').select('booking_date, start_time, facilities(name)')
          .eq('resident_id', residentId)
          .gte('booking_date', DateTime.now().toIso8601String().split('T')[0])
          .neq('status', 'cancelled')
          .order('booking_date', ascending: true)
          .order('start_time', ascending: true)
          .limit(1)
    ]);

    final fCount = (results[0] as PostgrestResponse).count ?? 0;
    final vCount = (results[1] as PostgrestResponse).count ?? 0;
    
    int openC = 0, inProgC = 0;
    for (var c in (results[2] as List)) {
      if (c['status'] == 'open') openC++;
      if (c['status'] == 'in_progress') inProgC++;
    }

    String bookingText = 'No upcoming bookings';
    final bookingsList = (results[3] as List);
    if (bookingsList.isNotEmpty) {
      final b = bookingsList[0];
      final facilityName = b['facilities'] != null ? b['facilities']['name'] ?? 'Facility' : 'Facility';
      final dateStr = b['booking_date'];
      
      try {
        final dateParts = dateStr.toString().split('-');
        final d = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        bookingText = 'Next: $facilityName, ${months[d.month - 1]} ${d.day}';
      } catch (_) {
        bookingText = 'Next: $facilityName, $dateStr';
      }
    }

    return ProfileStats(
      familyCount: fCount,
      vehiclesCount: vCount,
      openComplaints: openC,
      inProgressComplaints: inProgC,
      nextBookingInfo: bookingText,
    );
  }
}
