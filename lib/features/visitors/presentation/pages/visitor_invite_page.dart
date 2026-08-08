import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';
import '../widgets/guest_invite_card.dart';
import '../widgets/qr_code_display.dart';
import 'qr_scanner_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/guest_invite_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

class VisitorInvitePage extends StatefulWidget {
  const VisitorInvitePage({Key? key}) : super(key: key);

  @override
  State<VisitorInvitePage> createState() => _VisitorInvitePageState();
}

class _VisitorInvitePageState extends State<VisitorInvitePage> {
  late Future<List<GuestInviteModel>> _invitesFuture;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  bool _isGenerating = false;
  String? _generatedQrCode;
  String? _generatedOtp;
  bool _showAllInvites = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSetInvites();
  }
  
  void _fetchAndSetInvites() {
    setState(() {
      _invitesFuture = _fetchInvites();
    });
  }

  Future<void> _generatePass() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a guest name')));
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final inviteCode = 'VIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      final otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString(); // 6 digit OTP

      await Supabase.instance.client.from('visitors').insert({
        'id': const Uuid().v4(),
        'resident_id': currentUser.residentId,
        'apartment_id': currentUser.apartmentId,
        'society_id': currentUser.societyId,
        'guest_name': _nameController.text,
        'relation': 'friend',
        'purpose': _purposeController.text.isNotEmpty ? _purposeController.text : 'Visit',
        'invite_method': 'qr',
        'invite_code': inviteCode,
        'otp_value': otp,
        'valid_from': DateTime.now().toUtc().toIso8601String(),
        'valid_until': DateTime.now().add(const Duration(hours: 6)).toUtc().toIso8601String(),
        'valid_hours': 6,
        'status': 'active',
      });

      // Optimistic UI update
      setState(() {
        _generatedQrCode = inviteCode;
        _generatedOtp = otp;
        _isGenerating = false;
        _nameController.clear();
        _purposeController.clear();
      });
      _fetchAndSetInvites();
    } catch (e) {
      print('=== SUPABASE INSERT ERROR ===');
      print(e);
      print('=============================');
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _revokeInvite(String id) async {
    try {
      await Supabase.instance.client
          .from('visitors')
          .update({'status': 'cancelled'})
          .eq('id', id);
      _fetchAndSetInvites();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite revoked successfully.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to revoke: $e')));
    }
  }

  void _shareInvite() {
    if (_generatedQrCode == null) return;
    Share.share('Hi! Here is your visitor pass code: $_generatedQrCode. Please show this at the gate.');
  }

  Future<void> _shareWhatsApp() async {
    if (_generatedQrCode == null) return;
    final message = Uri.encodeComponent('Hi! Here is your visitor pass code: $_generatedQrCode. Please show this at the gate.');
    final url = Uri.parse('https://wa.me/?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
      }
    }
  }

  void _copyCode() {
    if (_generatedQrCode == null) return;
    Clipboard.setData(ClipboardData(text: _generatedQrCode!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<List<GuestInviteModel>> _fetchInvites() async {
    final response = await Supabase.instance.client
        .from('visitors')
        .select()
        .eq('resident_id', currentUser.residentId)
        .order('created_at', ascending: false);
    return (response as List).map((data) => GuestInviteModel.fromJson(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currentUser.societyName} · ${currentUser.block}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Invite a Guest',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
          // Guest Info Form
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    context,
                    label: 'Guest Name',
                    icon: 'user',
                    controller: _nameController,
                    hint: 'Enter guest name',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    context,
                    label: 'Purpose',
                    icon: 'info',
                    controller: _purposeController,
                    hint: 'e.g. Delivery, Friend',
                  ),
                ],
              ),
            ),
          ),
          
          if (_generatedQrCode == null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generatePass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isGenerating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Generate Pass', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ),
          
          if (_generatedQrCode != null) ...[
            // QR Code Display
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: QRCodeDisplay(
                  code: _generatedQrCode!,
                  name: _nameController.text.isNotEmpty ? _nameController.text : 'Guest',
                ),
              ),
            ),
          // Share Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share invite via',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareInvite,
                          icon: const CustomIcon(icon: 'share-2', size: 16, color: Colors.white),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareWhatsApp,
                          icon: CustomIcon(icon: 'message-circle', size: 16, color: theme.colorScheme.onSecondary),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _copyCode,
                        child: Container(
                          width: 48,
                          height: 52, // match button height approx
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CustomIcon(
                              icon: 'copy',
                              size: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_generatedQrCode != null)
            // OTP Pass Section
            SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'One-Time Password (Flat ${currentUser.apartment})',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _generatedOtp?.split('').join(' ') ?? '',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 8.0,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CustomIcon(icon: 'clock', size: 12, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                '5:42 left',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // muted
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              CustomIcon(icon: 'refresh-cw', size: 12, color: theme.colorScheme.onSurface),
                              const SizedBox(width: 6),
                              Text(
                                'Refresh',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _generatedQrCode = null;
                      _generatedOtp = null;
                    });
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
          ],
          
          // Recent Invites
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Invites',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAllInvites = !_showAllInvites;
                      });
                    },
                    child: Text(
                      _showAllInvites ? 'Show less' : 'See all',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: FutureBuilder<List<GuestInviteModel>>(
              future: _invitesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(child: Text('Error loading invites'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const CustomIcon(icon: 'users', size: 32, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 16),
                          Text('No past invites', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                          const SizedBox(height: 8),
                          Text('Invite a guest above to get started.', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  );
                }

                final invites = snapshot.data!;
                final displayedInvites = _showAllInvites ? invites : invites.take(5).toList();
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final invite = displayedInvites[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GuestInviteCard(
                          id: invite.id,
                          name: invite.name,
                          relation: invite.relation,
                          date: invite.date,
                          method: invite.method,
                          code: invite.code,
                          status: invite.status,
                          gender: invite.gender,
                          heritage: invite.heritage,
                          index: invite.avatarIndex,
                          validUntil: invite.validUntil,
                          otpValue: invite.otpValue,
                          unitNumber: currentUser.apartment,
                          onRevoke: invite.status == 'active' ? () => _revokeInvite(invite.id) : null,
                        ),
                      );
                    },
                    childCount: displayedInvites.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // padding for FAB/Navbar
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String icon,
    required TextEditingController controller,
    required String hint,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: CustomIcon(icon: icon, size: 16, color: const Color(0xFF64748B)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
