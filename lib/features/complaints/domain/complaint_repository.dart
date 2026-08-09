import '../../../core/models/complaint_model.dart';

abstract class ComplaintRepository {
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
  });
}
