import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/guest_invite_model.dart';
import 'package:uuid/uuid.dart';

class VisitorRepository {
  final SupabaseClient _supabase;

  VisitorRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<GuestInviteModel>> getInvites(String residentId) async {
    final response = await _supabase
        .from('visitors')
        .select()
        .eq('resident_id', residentId)
        .order('created_at', ascending: false);
    return (response as List).map((data) => GuestInviteModel.fromJson(data)).toList();
  }

  Future<Map<String, String>> createInvite({
    required String residentId,
    required String apartmentId,
    required String societyId,
    required String guestName,
    required String purpose,
  }) async {
    final inviteCode = 'VIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString(); // 6 digit OTP
    final validUntil = DateTime.now().add(const Duration(hours: 6)).toUtc().toIso8601String();

    await _supabase.from('visitors').insert({
      'id': const Uuid().v4(),
      'resident_id': residentId,
      'apartment_id': apartmentId,
      'society_id': societyId,
      'guest_name': guestName,
      'relation': 'friend',
      'purpose': purpose.isNotEmpty ? purpose : 'Visit',
      'invite_method': 'qr',
      'invite_code': inviteCode,
      'otp_value': otp,
      'valid_from': DateTime.now().toUtc().toIso8601String(),
      'valid_until': validUntil,
      'valid_hours': 6,
      'status': 'active',
    });

    return {
      'inviteCode': inviteCode,
      'otp': otp,
      'validUntil': validUntil,
    };
  }

  Future<void> revokeInvite(String inviteId) async {
    await _supabase
        .from('visitors')
        .update({'status': 'cancelled'})
        .eq('id', inviteId);
  }
}
