import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class NoticeModel {
  final int id; final String title; final String description; final String date;
  NoticeModel({required this.id, required this.title, required this.description, required this.date});
}

class NoticeProvider extends ChangeNotifier {
  List<NoticeModel> _notices = [];
  bool _isLoading = false;
  List<NoticeModel> get notices => _notices;
  bool get isLoading => _isLoading;

  Future<void> fetchNotices() async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _notices = [
      NoticeModel(id: 1, title: 'Annual Sports Day', description: 'Sports Day on 20 July 2025.', date: '16 Jun'),
      NoticeModel(id: 2, title: 'Exam Schedule', description: 'Mid-term exams from 20 June.', date: '15 Jun'),
      NoticeModel(id: 3, title: 'Fee Reminder', description: 'Last date for fee: 30 June.', date: '14 Jun'),
    ];
    _isLoading = false; notifyListeners();
  }

  Future<void> createNotice(String title, String description) async {
    final newId = _notices.isEmpty
        ? 1
        : _notices.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1;
    _notices.insert(
      0,
      NoticeModel(
        id: newId,
        title: title,
        description: description,
        date: DateFormat('d MMM').format(DateTime.now()),
      ),
    );
    notifyListeners();
  }
}

