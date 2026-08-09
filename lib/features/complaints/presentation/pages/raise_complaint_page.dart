import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/models/complaint_model.dart';
import '../../data/supabase_complaint_repository.dart';

class RaiseComplaintPage extends StatefulWidget {
  const RaiseComplaintPage({Key? key}) : super(key: key);

  @override
  State<RaiseComplaintPage> createState() => _RaiseComplaintPageState();
}

class _RaiseComplaintPageState extends State<RaiseComplaintPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _customLocationController = TextEditingController();

  final _repository = SupabaseComplaintRepository();
  final ImagePicker _picker = ImagePicker();

  int? _selectedCategoryIndex;
  bool _isSubmitting = false;
  bool _isEmergency = false;

  List<XFile> _selectedImages = [];
  final int _maxImages = 5;

  String? _selectedLocation;
  bool _isOtherLocation = false;

  ComplaintModel? _submittedComplaint;

  final List<String> categories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Security',
    'Lift',
    'Parking',
    'Other'
  ];

  final List<String> locations = [
    'My Apartment',
    'Common Area',
    'Parking Area',
    'Lobby',
    'Lift',
    'Other'
  ];

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) return;

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 70,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          final int remainingSlots = _maxImages - _selectedImages.length;
          _selectedImages.addAll(pickedFiles.take(remainingSlots));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= _maxImages) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to take photo: $e')));
      }
    }
  }

  void _showImageSourceActionSheet() {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 images allowed')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getFinalLocation() {
    if (_selectedLocation == 'My Apartment') {
      return currentUser.apartmentId;
    }
    if (_isOtherLocation) {
      return _customLocationController.text.trim().isNotEmpty
          ? _customLocationController.text.trim()
          : 'Other';
    }
    return _selectedLocation ?? '';
  }

  bool _validateForm() {
    if (_selectedCategoryIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return false;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a complaint title')));
      return false;
    }
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please describe the issue')));
      return false;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location')));
      return false;
    }
    if (_isOtherLocation && _customLocationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please specify the custom location')));
      return false;
    }
    return true;
  }

  Future<void> _submitComplaint() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final imagePaths = _selectedImages.map((e) => e.path).toList();
      final finalLocation = _getFinalLocation();

      final complaint = await _repository.createComplaint(
        residentId: currentUser.residentId,
        apartmentId: currentUser.apartmentId,
        societyId: currentUser.societyId,
        title: _titleController.text.trim(),
        category: categories[_selectedCategoryIndex!],
        description: _descController.text.trim(),
        imagePaths: imagePaths,
        location: finalLocation,
        isEmergency: _isEmergency,
      );

      if (mounted) {
        setState(() {
          _submittedComplaint = complaint;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _resetForm() {
    setState(() {
      _submittedComplaint = null;
      _titleController.clear();
      _descController.clear();
      _customLocationController.clear();
      _selectedCategoryIndex = null;
      _selectedLocation = null;
      _isOtherLocation = false;
      _isEmergency = false;
      _selectedImages.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_submittedComplaint != null) {
      return _buildSuccessState(theme);
    }

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
                          currentUser.societyName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'Raise Complaint',
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
          // Info Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CustomIcon(
                        icon: 'info',
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Describe your issue in detail. Include photos if possible. Our team will review and respond shortly.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Form Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    'Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(categories.length, (index) {
                        final isSelected = index == _selectedCategoryIndex;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedCategoryIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : const Color(0xFFE8EDF3),
                                ),
                              ),
                              child: Text(
                                categories[index],
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Complaint Title',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA), // input
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EDF3)),
                    ),
                    child: TextField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'e.g., Water leaking from ceiling',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    constraints: const BoxConstraints(minHeight: 120),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA), // input
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EDF3)),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 5,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue in detail…',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload Images
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload Images (Optional)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_selectedImages.length}/$_maxImages',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_selectedImages.isEmpty)
                    GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE8EDF3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const CustomIcon(
                              icon: 'image-plus',
                              size: 24,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to upload photos',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._selectedImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.network(
                                            file.path,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(file.path),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (_selectedImages.length < _maxImages)
                            GestureDetector(
                              onTap: _showImageSourceActionSheet,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F6FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE8EDF3),
                                  ),
                                ),
                                child: const Center(
                                  child: CustomIcon(
                                    icon: 'plus',
                                    size: 24,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Location
                  Text(
                    'Location',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EDF3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'Select Location',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        value: _selectedLocation,
                        icon: const CustomIcon(
                          icon: 'chevron-down',
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        items: locations.map((String location) {
                          return DropdownMenuItem<String>(
                            value: location,
                            child: Text(location),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLocation = newValue;
                            _isOtherLocation = newValue == 'Other';
                          });
                        },
                      ),
                    ),
                  ),

                  if (_isOtherLocation) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8EDF3)),
                      ),
                      child: TextField(
                        controller: _customLocationController,
                        decoration: InputDecoration(
                          hintText: 'Enter specific location',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Emergency / Safety Issue
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Switch(
                        value: _isEmergency,
                        onChanged: (value) {
                          setState(() {
                            _isEmergency = value;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Safety or emergency issue?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (_isEmergency)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'For immediate danger, contact security or emergency services directly. Complaint submission may not provide immediate assistance.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Submit Complaint',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.green.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Complaint Submitted Successfully',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EDF3)),
                ),
                child: Column(
                  children: [
                    _buildTicketRow('Ticket ID', _submittedComplaint?.ticketId ?? '', theme),
                    const Divider(height: 24, color: Color(0xFFE8EDF3)),
                    _buildTicketRow('Category', _submittedComplaint?.category ?? '', theme),
                    const Divider(height: 24, color: Color(0xFFE8EDF3)),
                    _buildTicketRow('Location', _submittedComplaint?.location ?? '', theme),
                    const Divider(height: 24, color: Color(0xFFE8EDF3)),
                    _buildTicketRow('Date', _submittedComplaint?.createdAt != null
                        ? _submittedComplaint!.createdAt!.split('T').first
                        : 'Today', theme),
                    const Divider(height: 24, color: Color(0xFFE8EDF3)),
                    _buildTicketRow('Status', _submittedComplaint?.status.toUpperCase() ?? 'SUBMITTED', theme, isStatus: true),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tracking feature coming soon')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Track Complaint',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Back to Complaints',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow(String label, String value, ThemeData theme, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF64748B),
          ),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
