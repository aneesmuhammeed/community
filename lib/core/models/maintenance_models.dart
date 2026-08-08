class OutstandingDueModel {
  final String id;
  final String title;
  final double amount;
  final String dueDate;
  final bool isOverdue;

  OutstandingDueModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isOverdue,
  });

  factory OutstandingDueModel.fromJson(Map<String, dynamic> json) {
    return OutstandingDueModel(
      id: json['id'] as String? ?? '',
      title: '${json['billing_month']} Maintenance',
      amount: (json['amount_due'] as num?)?.toDouble() ?? (json['total_amount'] as num).toDouble(),
      dueDate: json['due_date'] as String,
      isOverdue: json['status'] == 'overdue' || json['status'] == 'pending',
    );
  }
}

class BillingHistoryModel {
  final String id;
  final String title;
  final double amount;
  final String date;
  final String status;

  BillingHistoryModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory BillingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BillingHistoryModel(
      id: json['id'] as String,
      title: '${json['billing_month']} Maintenance',
      amount: (json['total_amount'] as num).toDouble(),
      date: json['paid_at'] != null ? json['paid_at'] as String : json['due_date'] as String,
      status: json['status'] as String,
    );
  }
}

class ExpenseModel {
  final String id;
  final String title;
  final int percentage;
  final String colorHex;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.percentage,
    required this.colorHex,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      percentage: json['percentage'] as int,
      colorHex: json['color_hex'] as String,
    );
  }
}
