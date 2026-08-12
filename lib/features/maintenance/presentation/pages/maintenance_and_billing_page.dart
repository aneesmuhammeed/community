import '../../../../core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../widgets/outstanding_dues_card.dart';
import '../widgets/payment_summary_row.dart';
import '../widgets/billing_history_item.dart';
import '../widgets/expense_breakdown.dart';
import '../widgets/payment_methods.dart';
import '../widgets/recent_transaction.dart';
import '../../../../core/models/maintenance_models.dart';
import '../../data/billing_repository.dart';
import '../../../../core/models/maintenance_models.dart';
import 'package:community_hub/features/layout/presentation/pages/notifications_page.dart';

class MaintenanceAndBillingPage extends ConsumerStatefulWidget {
  const MaintenanceAndBillingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MaintenanceAndBillingPage> createState() => _MaintenanceAndBillingPageState();
}

class _MaintenanceAndBillingPageState extends ConsumerState<MaintenanceAndBillingPage> {
  bool _isLoading = true;
  List<OutstandingDueModel> _dues = [];
  List<BillingHistoryModel> _history = [];
  final _repository = BillingRepository();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _repository.getOutstandingDues(ref.read(userProvider)!.apartmentId),
        _repository.getBillingHistory(ref.read(userProvider)!.apartmentId),
      ]);

      if (mounted) {
        setState(() {
          _dues = results[0] as List<OutstandingDueModel>;
          _history = results[1] as List<BillingHistoryModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(userProvider)!.societyName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'Maintenance & Billing',
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
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NotificationsPage()),
                              ),
                              child: CustomIcon(
                                icon: 'bell',
                                size: 18,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          // Unread badge
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Outstanding Dues
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _dues.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: OutstandingDuesCard(
                          amount: _dues.first.amount.toInt(),
                          dueDate: _dues.first.dueDate,
                          status: _dues.first.isOverdue ? 'overdue' : 'pending',
                        ),
                      ),
          ),
          // Payment Summary
          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: PaymentSummaryRow(
                      paidThisYear: 42000,
                      pendingAmount: _dues.isNotEmpty ? _dues.first.amount.toInt() : 0,
                      nextDueDate: _dues.isNotEmpty ? _dues.first.dueDate : '—',
                    ),
                  ),
          ),
          // Billing History
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billing History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EDF3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2850).withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())
                        : _history.isEmpty
                            ? const Padding(padding: EdgeInsets.all(20), child: Text('No billing history found.'))
                            : Column(
                                children: _history.map((item) {
                                  return BillingHistoryItem(
                                    month: item.title,
                                    amount: item.amount.toInt(),
                                    dueDate: item.date,
                                    status: item.status,
                                    paidDate: item.status == 'paid' ? item.date : '—',
                                  );
                                }).toList(),
                              ),
                  ),
                ],
              ),
            ),
          ),
          // Expense Breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const ExpenseBreakdown(),
                ],
              ),
            ),
          ),
          // Payment Methods
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Methods',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const SizedBox.shrink()
                      : PaymentMethods(
                          amount: _dues.isNotEmpty ? _dues.first.amount.toInt() : 0,
                          billingMonth: _dues.isNotEmpty ? _dues.first.title.replaceAll(' Maintenance', '') : '',
                        ),
                ],
              ),
            ),
          ),
          // Recent Transactions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8EDF3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2850).withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        RecentTransaction(
                          date: 'Nov 25, 2024',
                          amount: 3500,
                          method: 'UPI (GooglePay)',
                          methodType: 'upi',
                          status: 'success',
                          refNo: '#TXN20241125001',
                        ),
                        RecentTransaction(
                          date: 'Nov 15, 2024',
                          amount: 3500,
                          method: 'Debit Card',
                          methodType: 'card',
                          status: 'success',
                          refNo: '#TXN20241115002',
                        ),
                        RecentTransaction(
                          date: 'Oct 25, 2024',
                          amount: 3500,
                          method: 'Net Banking',
                          methodType: 'netbanking',
                          status: 'pending',
                          refNo: '#TXN20241025003',
                        ),
                        RecentTransaction(
                          date: 'Sep 20, 2024',
                          amount: 3200,
                          method: 'Digital Wallet',
                          methodType: 'wallet',
                          status: 'success',
                          refNo: '#TXN20240920004',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // padding for FAB/Navbar
        ],
      ),
    );
  }
}
