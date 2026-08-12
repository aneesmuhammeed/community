import '../../../../core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/family_member_model.dart';
import '../../data/profile_repository.dart';
import '../widgets/add_family_member_modal.dart';

class FamilyMembersPage extends ConsumerStatefulWidget {
  const FamilyMembersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends ConsumerState<FamilyMembersPage> {
  bool _isLoading = true;
  List<FamilyMemberModel> _members = [];
  final _repository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final res = await _repository.getFamilyMembers(ref.read(userProvider)!.residentId);

      if (mounted) {
        setState(() {
          _members = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading members: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMember(String id) async {
    try {
      await _repository.deleteFamilyMember(id);
      _fetchMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting member: $e')));
      }
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddFamilyMemberModal(),
    ).then((added) {
      if (added == true) {
        setState(() => _isLoading = true);
        _fetchMembers();
      }
    });
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
        title: Text(
          'Family Members',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 24, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _fetchMembers,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _members.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final m = _members[index];
                      return _buildMemberCard(theme, m);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: theme.colorScheme.primary,
        child: const CustomIcon(icon: 'plus', color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const CustomIcon(icon: 'users', size: 32, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          Text(
            'No Family Members',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add members living with you in the apartment',
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ThemeData theme, FamilyMemberModel member) {
    final ext = theme.extension<AppThemeExtension>()!;
    
    // Choose icon based on relation/gender roughly
    String iconStr = 'user';
    if (member.ageGroup == 'Child') iconStr = 'baby';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2850).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ext.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIcon(
                icon: iconStr,
                size: 20,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${member.relation} · ${member.ageGroup}',
                  style: theme.textTheme.labelSmall?.copyWith(color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const CustomIcon(icon: 'trash-2', size: 20, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(member.id, member.name),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text('Are you sure you want to remove $name from your family?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteMember(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
