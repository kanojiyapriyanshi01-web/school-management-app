import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class FeeModel {
  final int id;
  final int studentId;
  final String studentName;
  final String feeType;
  final double amount;
  final double paidAmount;
  final String status;
  final String dueDate;
  final String paidDate;

  FeeModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.feeType,
    required this.amount,
    required this.paidAmount,
    required this.status,
    required this.dueDate,
    required this.paidDate,
  });

  double get pending => amount - paidAmount;

  factory FeeModel.fromJson(Map<String, dynamic> j) => FeeModel(
    id: j['id'] ?? 0,
    studentId: j['student_id'] ?? 0,
    studentName: j['student_name'] ?? j['student']?['name'] ?? 'Unknown',
    feeType: j['fee_type'] ?? '',
    amount: (j['amount'] ?? 0).toDouble(),
    paidAmount: (j['paid_amount'] ?? 0).toDouble(),
    status: j['status'] ?? 'pending',
    dueDate: j['due_date'] ?? '',
    paidDate: j['paid_date'] ?? '',
  );
}

class FeeProvider extends ChangeNotifier {
  List<FeeModel> _fees = [];
  bool _isLoading = false;

  List<FeeModel> get fees => _fees;
  bool get isLoading => _isLoading;
  double get totalCollected => _fees.where((f) => f.status == 'paid').fold(0, (s, f) => s + f.amount);
  double get totalPending => _fees.where((f) => f.status == 'pending' || f.status == 'partial').fold(0, (s, f) => s + f.amount);
  double get totalOverdue => _fees.where((f) => f.status == 'overdue').fold(0, (s, f) => s + f.amount);

  Future<void> fetchFees() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.get('/fees');
      final data = response['data'] as List? ?? [];
      _fees = data.map((j) => FeeModel.fromJson(j)).toList();
    } catch (e) {
      _fees = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateFeeStatus(int id, String status) async {
    try {
      await apiService.put('/fees/$id', {'status': status});
      await fetchFees();
      return true;
    } catch (e) {
      return false;
    }
  }
}



