import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../widgets/outstanding_dues_card.dart';
import '../widgets/payment_summary_row.dart';
import '../widgets/billing_history_item.dart';
import '../widgets/expense_breakdown.dart';
import '../widgets/payment_methods.dart';
import '../widgets/recent_transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/maintenance_models.dart';

class MaintenanceAndBillingPage extends StatefulWidget {
  const MaintenanceAndBillingPage({Key? key}) : super(key: key);

  @override
  State<MaintenanceAndBillingPage> createState() => _MaintenanceAndBillingPageState();
}

class _MaintenanceAndBillingPageState extends State<MaintenanceAndBillingPage> {
  late Future<List<OutstandingDueModel>> _duesFuture;
  late Future<List<BillingHistoryModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _duesFuture = _fetchDues();
    _historyFuture = _fetchHistory();
  }

  Future<List<OutstandingDueModel>> _fetchDues() async {
    final response = await Supabase.instance.client
        .from('billing_cycles')
        .select()
        .or('status.eq.pending,status.eq.overdue')
        .order('due_date', ascending: false);
    return (response as List).map((data) => OutstandingDueModel.fromJson(data)).toList();
  }

  Future<List<BillingHistoryModel>> _fetchHistory() async {
    final response = await Supabase.instance.client
        .from('billing_cycles')
        .select()
        .eq('status', 'paid')
        .order('created_at', ascending: false);
    return (response as List).map((data) => BillingHistoryModel.fromJson(data)).toList();
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
                          currentUser.societyName,
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
          // Outstanding Dues
          SliverToBoxAdapter(
            child: FutureBuilder<List<OutstandingDueModel>>(
              future: _duesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                final due = snapshot.data!.first;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: OutstandingDuesCard(
                    amount: due.amount.toInt(),
                    dueDate: due.dueDate,
                    status: due.isOverdue ? 'overdue' : 'pending',
                  ),
                );
              },
            ),
          ),
          // Payment Summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: const PaymentSummaryRow(
                paidThisYear: 42000,
                pendingAmount: 3500,
                nextDueDate: 'Dec 5, 2024',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Billing History',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'View all',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                    child: FutureBuilder<List<BillingHistoryModel>>(
                      future: _historyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator());
                        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(padding: EdgeInsets.all(20), child: Text('No billing history found.'));
                        }

                        final history = snapshot.data!;
                        return Column(
                          children: history.map((item) {
                            return BillingHistoryItem(
                              month: item.title,
                              amount: item.amount.toInt(),
                              dueDate: item.date,
                              status: item.status,
                              paidDate: item.status == 'paid' ? item.date : '—',
                            );
                          }).toList(),
                        );
                      },
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
                  const PaymentMethods(),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'View all',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
