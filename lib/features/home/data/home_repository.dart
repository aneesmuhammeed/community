import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/guest_invite_model.dart';
import '../../../../core/models/announcement_model.dart';

class HomeRepository {
  final SupabaseClient _client;

  HomeRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<GuestInviteModel>> getVisitors(String residentId) async {
    final response = await _client
        .from('visitors')
        .select()
        .eq('resident_id', residentId)
        .order('created_at', ascending: false);
    return (response as List).map((data) => GuestInviteModel.fromJson(data)).toList();
  }

  Future<List<AnnouncementModel>> getAnnouncements(String societyId) async {
    final response = await _client
        .from('announcements')
        .select()
        .eq('society_id', societyId)
        .eq('is_published', true)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);
    return (response as List).map((data) => AnnouncementModel.fromJson(data)).toList();
  }
}
