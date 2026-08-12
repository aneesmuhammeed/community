import '../../../core/models/complaint_model.dart';
import 'package:image_picker/image_picker.dart';

abstract class ComplaintRepository {
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
  });
}
