import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    required List<XFile> images,
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

      final List<String> uploadedPaths = [];

      if (images.isNotEmpty) {
        final List<Map<String, dynamic>> imageInserts = [];
        
        for (final xfile in images) {
          final ext = xfile.name.split('.').last;
          final storagePath = '$id/${_uuid.v4()}.$ext';
          
          if (kIsWeb) {
            final bytes = await xfile.readAsBytes();
            await _client.storage.from('complaints').uploadBinary(
              storagePath, 
              bytes,
              fileOptions: FileOptions(contentType: xfile.mimeType ?? 'image/$ext'),
            );
          } else {
            await _client.storage.from('complaints').upload(
              storagePath, 
              File(xfile.path),
              fileOptions: FileOptions(contentType: xfile.mimeType ?? 'image/$ext'),
            );
          }
          
          final publicUrl = _client.storage.from('complaints').getPublicUrl(storagePath);
          uploadedPaths.add(publicUrl);

          imageInserts.add({
            'id': _uuid.v4(),
            'complaint_id': id,
            'storage_path': publicUrl,
            'uploaded_at': now,
          });
        }

        await _client.from('complaint_images').insert(imageInserts);
      }

      return ComplaintModel(
        id: id,
        residentId: residentId,
        apartmentId: apartmentId,
        title: title,
        category: category,
        description: description,
        images: uploadedPaths,
        location: location,
        isEmergency: isEmergency,
        status: 'open',
        createdAt: now,
        ticketId: id.substring(0, 8).toUpperCase(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
