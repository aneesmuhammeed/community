import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_model.dart';

class PaymentPage extends StatefulWidget {
  final String paymentMethod; // 'upi' | 'card' | 'netbanking' | 'wallet'
  final String methodLabel;
  final int amount;
  final String billingMonth;

  const PaymentPage({
    Key? key,
    required this.paymentMethod,
    required this.methodLabel,
    required this.amount,
    required this.billingMonth,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isSuccess = false;
  late AnimationController _checkController;
  late Animation<double> _checkAnim;

  // UPI
  final _upiController = TextEditingController();
  String _selectedUpiApp = 'GooglePay';
  final _upiApps = ['GooglePay', 'PhonePe', 'Paytm', 'BHIM'];

  // Card
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Net Banking
  String _selectedBank = 'SBI';
  final _banks = ['SBI', 'HDFC Bank', 'ICICI Bank', 'Axis Bank', 'Kotak Bank', 'PNB'];

  // Wallet
  String _selectedWallet = 'Paytm';
  final _wallets = ['Paytm', 'PhonePe Wallet', 'Amazon Pay', 'Mobikwik'];

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _checkAnim = CurvedAnimation(parent: _checkController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _checkController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    // Basic validation
    if (widget.paymentMethod == 'upi' && _upiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your UPI ID')),
      );
      return;
    }
    if (widget.paymentMethod == 'card') {
      if (_cardNumberController.text.replaceAll(' ', '').length < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid card number')),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      _checkController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    if (_isSuccess) return _buildSuccessView(theme, ext);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIcon(icon: 'chevron-left', size: 22, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.methodLabel,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Amount card
          Container(
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.billingMonth,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maintenance Due',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${widget.amount}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Payment form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPaymentForm(theme, ext),
                  const SizedBox(height: 24),
                  // Security note
                  Row(
                    children: [
                      const CustomIcon(icon: 'shield-check', size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        'Secured by 256-bit SSL encryption',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Pay button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Pay ₹${widget.amount}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(ThemeData theme, AppThemeExtension ext) {
    switch (widget.paymentMethod) {
      case 'upi':
        return _buildUpiForm(theme, ext);
      case 'card':
        return _buildCardForm(theme);
      case 'netbanking':
        return _buildNetBankingForm(theme, ext);
      case 'wallet':
        return _buildWalletForm(theme, ext);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUpiForm(ThemeData theme, AppThemeExtension ext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select UPI App', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: _upiApps.map((app) {
            final selected = _selectedUpiApp == app;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedUpiApp = app),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? theme.colorScheme.primary : const Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? theme.colorScheme.primary : const Color(0xFFE8EDF3),
                    ),
                  ),
                  child: Text(
                    app,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('UPI ID', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _upiController,
          hint: 'yourname@upi',
          keyboardType: TextInputType.emailAddress,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildCardForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Number', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _cardNumberController,
          hint: '1234  5678  9012  3456',
          keyboardType: TextInputType.number,
          theme: theme,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          maxLength: 19,
        ),
        const SizedBox(height: 16),
        Text('Cardholder Name', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _cardNameController,
          hint: 'Name on card',
          keyboardType: TextInputType.name,
          theme: theme,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expiry', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _expiryController,
                    hint: 'MM/YY',
                    keyboardType: TextInputType.number,
                    theme: theme,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ExpiryFormatter(),
                    ],
                    maxLength: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CVV', style: theme.textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _cvvController,
                    hint: '•••',
                    keyboardType: TextInputType.number,
                    theme: theme,
                    obscureText: true,
                    maxLength: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetBankingForm(ThemeData theme, AppThemeExtension ext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Bank', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._banks.map((bank) {
          final selected = _selectedBank == bank;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedBank = bank),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? theme.colorScheme.secondary : const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? theme.colorScheme.primary : const Color(0xFFE8EDF3),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIcon(
                      icon: 'building-2',
                      size: 18,
                      color: selected ? theme.colorScheme.primary : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bank,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (selected)
                      CustomIcon(icon: 'check', size: 16, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWalletForm(ThemeData theme, AppThemeExtension ext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Wallet', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._wallets.map((wallet) {
          final selected = _selectedWallet == wallet;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedWallet = wallet),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? ext.aiSoft : const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? ext.ai : const Color(0xFFE8EDF3),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIcon(icon: 'wallet', size: 18, color: selected ? ext.ai : const Color(0xFF64748B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        wallet,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? ext.ai : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (selected) CustomIcon(icon: 'check', size: 16, color: ext.ai),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required ThemeData theme,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme, AppThemeExtension ext) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _checkAnim,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: ext.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, size: 56, color: Color(0xFF10B981)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '₹${widget.amount} paid for ${widget.billingMonth}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EDF3)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Amount', '₹${widget.amount}', theme),
                    const Divider(height: 20, color: Color(0xFFE8EDF3)),
                    _buildReceiptRow('Method', widget.methodLabel, theme),
                    const Divider(height: 20, color: Color(0xFFE8EDF3)),
                    _buildReceiptRow('Billing', widget.billingMonth, theme),
                    const Divider(height: 20, color: Color(0xFFE8EDF3)),
                    _buildReceiptRow('Status', '✓ Success', theme, valueColor: const Color(0xFF10B981)),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Back to Maintenance',
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, ThemeData theme, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B))),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// Card number formatter: adds space every 4 digits
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Expiry formatter: adds / after MM
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length >= 3) {
      final formatted = '${text.substring(0, 2)}/${text.substring(2)}';
      return newValue.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    return newValue;
  }
}
