import 'package:flutter/foundation.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceStudent {
  final int id;
  final String name;
  final String rollNo;
  AttendanceStatus status;
  AttendanceStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    this.status = AttendanceStatus.present,
  });
}

class AttendanceProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  String _selectedClass = classOptions.first;
  bool _isLoading = false;
  List<AttendanceStudent> _students = [];

  static const List<String> classOptions = [
        'Class 10-A',
        'Class 10-B',
        'Class 9-A',
        'Class 9-B',
        'Class 8-A',
  ];

  DateTime get selectedDate => _selectedDate;
  String get selectedClass => _selectedClass;
  bool get isLoading => _isLoading;
  List<AttendanceStudent> get students => _students;

  int get presentCount => _students.where((s) => s.status == AttendanceStatus.present).length;
  int get absentCount => _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get lateCount => _students.where((s) => s.status == AttendanceStatus.late).length;
  int get totalCount => _students.length;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> setClass(String className) async {
    _selectedClass = className;
    await fetchStudentsForClass();
  }

  Future<void> fetchStudentsForClass() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: replace mock data with an API call to your Go backend,
    // fetching students for `_selectedClass` on `_selectedDate`
    _students = [
      AttendanceStudent(id: 1, name: 'Rahul Kumar', rollNo: 'R001'),
      AttendanceStudent(id: 2, name: 'Priya Singh', rollNo: 'R002'),
      AttendanceStudent(id: 3, name: 'Amit Sharma', rollNo: 'R003', status: AttendanceStatus.absent),
      AttendanceStudent(id: 4, name: 'Sneha Patel', rollNo: 'R004'),
    ];
    _isLoading = false;
    notifyListeners();
  }

  void markStatus(int studentId, AttendanceStatus status) {
    final student = _students.firstWhere((s) => s.id == studentId);
    student.status = status;
    notifyListeners();
  }

  Future<bool> saveAttendance() async {
    // TODO: send _students + _selectedDate + _selectedClass to your Go backend
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}

