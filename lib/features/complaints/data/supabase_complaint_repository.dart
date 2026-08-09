import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/complaint_model.dart';
import '../domain/complaint_repository.dart';

class SupabaseComplaintRepository implements ComplaintRepository {
  final SupabaseClient _client;
  final Uuid _uuid = const Uuid();

  SupabaseComplaintRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<ComplaintModel> createComplaint({
    required String? residentId,
    required String? apartmentId,
    required String societyId,
    required String title,
    required String category,
    required String description,
    required List<String> imagePaths,
    required String location,
    required bool isEmergency,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();

    final Map<String, dynamic> insertData = {
      'id': id,
      'resident_id': residentId,
      'apartment_id': apartmentId,
      'society_id': societyId,
      'category': category.toLowerCase(),
      'title': title,
      'description': description,
      'status': 'open', // Postgres enums are typically lowercase
      'priority': isEmergency ? 'high' : 'medium',
      'location_label': location,
      'created_at': now,
      'updated_at': now,
    };

    try {
      await _client.from('complaints').insert(insertData);

      if (imagePaths.isNotEmpty) {
        final List<Map<String, dynamic>> imageInserts = imagePaths.map((path) => {
          'id': _uuid.v4(),
          'complaint_id': id,
          'storage_path': path,
          // 'uploaded_by': residentId, // Commented out to avoid foreign key violation with mock data
          'uploaded_at': now,
        }).toList();

        await _client.from('complaint_images').insert(imageInserts);
      }
    } catch (e) {
      rethrow;
    }

    return ComplaintModel(
      id: id,
      residentId: residentId,
      apartmentId: apartmentId,
      title: title,
      category: category,
      description: description,
      images: imagePaths, // Storing local paths for immediate UI feedback if needed
      location: location,
      isEmergency: isEmergency,
      status: 'open',
      createdAt: now,
      ticketId: id.substring(0, 8).toUpperCase(),
    );
  }
}
