import '../../../../core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/user_avatar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  String _gender = 'male';
  String _ageGroup = '25-35';
  String _heritage = 'South Asian';
  int _avatarIndex = 0;
  
  bool _isSaving = false;

  final _genders = ['male', 'female', 'other'];
  final _ageGroups = ['18-24', '25-35', '36-45', '46-60', '60+'];
  final _heritages = ['South Asian', 'East Asian', 'Caucasian', 'African', 'Hispanic', 'Middle Eastern', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: ref.read(userProvider)!.name);
    _phoneCtrl = TextEditingController(text: ref.read(userProvider)!.phone);
    _emailCtrl = TextEditingController(text: ref.read(userProvider)!.email);

    _gender = ref.read(userProvider)!.gender;
    _ageGroup = ref.read(userProvider)!.ageGroup;
    _heritage = ref.read(userProvider)!.heritage;
    _avatarIndex = ref.read(userProvider)!.avatarIndex;
    
    // Fallbacks in case user model has invalid values not in dropdown
    if (!_genders.contains(_gender)) _gender = 'other';
    if (!_ageGroups.contains(_ageGroup)) _ageGroup = '25-35';
    if (!_heritages.contains(_heritage)) _heritage = 'Other';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;

      // Update resident_profiles table
      await supabase.from('resident_profiles').update({
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'gender': _gender,
        'age_group': _ageGroup,
        'heritage': _heritage,
        'avatar_index': _avatarIndex,
      }).eq('id', ref.read(userProvider)!.residentId);

      // Update local state in memory
      ref.read(userProvider.notifier).setUser(ref.read(userProvider)!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        gender: _gender,
        ageGroup: _ageGroup,
        heritage: _heritage,
        avatarIndex: _avatarIndex,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text('Edit Profile', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 24, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _avatarIndex = (_avatarIndex + 1) % 100;
                    });
                  },
                  child: Stack(
                    children: [
                      UserAvatar(
                        gender: _gender,
                        ageGroup: _ageGroup,
                        heritage: _heritage,
                        index: _avatarIndex,
                        size: 80,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.surface, width: 2),
                          ),
                          child: Center(
                            child: CustomIcon(
                              icon: 'refresh-cw',
                              size: 14,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Tap to change avatar', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(theme, 'Personal Information'),
              _buildTextField('Full Name', _nameCtrl),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', _phoneCtrl),
              const SizedBox(height: 16),
              _buildTextField('Email Address', _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecoration('Gender'),
                      items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _ageGroup,
                      decoration: _inputDecoration('Age Group'),
                      items: _ageGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _ageGroup = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _heritage,
                decoration: _inputDecoration('Heritage / Background'),
                items: _heritages.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _heritage = v!),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool readOnly = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: readOnly ? Colors.grey.shade700 : null),
      decoration: _inputDecoration(label).copyWith(
        fillColor: readOnly ? Colors.grey.shade100 : null,
        filled: readOnly,
      ),
      validator: readOnly ? null : (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }
  
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
