import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/maintenance_models.dart';

class BillingRepository {
  final SupabaseClient _supabase;

  BillingRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<OutstandingDueModel>> getOutstandingDues(String apartmentId) async {
    final response = await _supabase
        .from('billing_cycles')
        .select()
        .eq('apartment_id', apartmentId)
        .or('status.eq.pending,status.eq.overdue')
        .order('due_date', ascending: false);
    return (response as List).map((data) => OutstandingDueModel.fromJson(data)).toList();
  }

  Future<List<BillingHistoryModel>> getBillingHistory(String apartmentId) async {
    final response = await _supabase
        .from('billing_cycles')
        .select()
        .eq('apartment_id', apartmentId)
        .eq('status', 'paid')
        .order('created_at', ascending: false);
    return (response as List).map((data) => BillingHistoryModel.fromJson(data)).toList();
  }
}
