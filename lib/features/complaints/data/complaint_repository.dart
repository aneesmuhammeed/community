import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/complaint_model.dart';

class ComplaintRepository {
  final SupabaseClient _supabase;

  ComplaintRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<ComplaintModel>> getComplaints(String residentId) async {
    final response = await _supabase
        .from('complaints')
        .select('*, complaint_images(storage_path)')
        .eq('resident_id', residentId)
        .order('created_at', ascending: false);
        
    return (response as List).map((data) {
      final images = (data['complaint_images'] as List<dynamic>?)
          ?.map((e) => e['storage_path'] as String)
          .toList() ?? [];
      data['images'] = images;
      return ComplaintModel.fromJson(data);
    }).toList();
  }
}
