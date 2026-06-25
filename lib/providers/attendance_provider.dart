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

class AttendanceRecord {
  final String className;
  final DateTime date;
  final List<AttendanceStudent> students;
  final int presentCount;
  final int absentCount;
  final int lateCount;

  AttendanceRecord({
    required this.className,
    required this.date,
    required this.students,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });
}

class AttendanceProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  String _selectedClass = classOptions.first;
  bool _isLoading = false;
  List<AttendanceStudent> _students = [];

  // Map of "className|date" -> saved record
  final Map<String, AttendanceRecord> _savedAttendance = {};

  // Full history list (most recent first)
  final List<AttendanceRecord> _history = [];

  // --- All classes: Nursery to 12 + Staff ---
  static const List<String> classOptions = [
    'Nursery',
    'LKG',
    'UKG',
    'Class 1-A',
    'Class 2-A',
    'Class 3-A',
    'Class 4-A',
    'Class 5-A',
    'Class 6-A',
    'Class 7-A',
    'Class 8-A',
    'Class 9-A',
    'Class 9-B',
    'Class 10-A',
    'Class 10-B',
    'Class 11 (Science)',
    'Class 11 (Commerce)',
    'Class 12 (Science)',
    'Class 12 (Commerce)',
    'Staff',
  ];

  DateTime get selectedDate => _selectedDate;
  String get selectedClass => _selectedClass;
  bool get isLoading => _isLoading;
  List<AttendanceStudent> get students => _students;
  List<AttendanceRecord> get history => List.unmodifiable(_history);

  int get presentCount => _students.where((s) => s.status == AttendanceStatus.present).length;
  int get absentCount => _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get lateCount => _students.where((s) => s.status == AttendanceStatus.late).length;
  int get totalCount => _students.length;

  String _key(String className, DateTime date) =>
      '$className|${date.year}-${date.month}-${date.day}';

  bool get isCurrentAttendanceSaved =>
      _savedAttendance.containsKey(_key(_selectedClass, _selectedDate));

  void setDate(DateTime date) {
    _selectedDate = date;
    fetchStudentsForClass();
  }

  Future<void> setClass(String className) async {
    _selectedClass = className;
    await fetchStudentsForClass();
  }

  Future<void> fetchStudentsForClass() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    // If already saved for this class+date, load saved data
    final key = _key(_selectedClass, _selectedDate);
    if (_savedAttendance.containsKey(key)) {
      _students = List<AttendanceStudent>.from(_savedAttendance[key]!.students);
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Otherwise load fresh mock data
    // TODO: replace with API call to your Go backend
    if (_selectedClass == 'Staff') {
      _students = _mockStaff();
    } else {
      _students = _mockStudents(_selectedClass);
    }

    _isLoading = false;
    notifyListeners();
  }

  void markStatus(int studentId, AttendanceStatus status) {
    if (isCurrentAttendanceSaved) return; // locked after save
    final student = _students.firstWhere((s) => s.id == studentId);
    student.status = status;
    notifyListeners();
  }

  Future<bool> saveAttendance() async {
    if (isCurrentAttendanceSaved) return false;
    // TODO: send to your Go backend
    await Future.delayed(const Duration(milliseconds: 400));

    final record = AttendanceRecord(
      className: _selectedClass,
      date: _selectedDate,
      students: List<AttendanceStudent>.from(_students),
      presentCount: presentCount,
      absentCount: absentCount,
      lateCount: lateCount,
    );

    final key = _key(_selectedClass, _selectedDate);
    _savedAttendance[key] = record;
    _history.insert(0, record);
    notifyListeners();
    return true;
  }

  // ---------- Mock data ----------

  List<AttendanceStudent> _mockStudents(String cls) {
    final names = {
      'Nursery': ['Aarav Sharma', 'Diya Patel', 'Riya Gupta', 'Aryan Singh', 'Pooja Mehta'],
      'LKG': ['Kabir Joshi', 'Ananya Rao', 'Vivaan Kumar', 'Nisha Verma'],
      'UKG': ['Ishaan Nair', 'Prisha Reddy', 'Aadi Shah', 'Meera Pillai', 'Rohan Das'],
      'Class 9-A': ['Rahul Kumar', 'Priya Singh', 'Amit Sharma', 'Sneha Patel', 'Rohan Verma', 'Kavya Reddy', 'Arjun Mehta', 'Divya Nair'],
      'Class 10-A': ['Rahul Kumar', 'Priya Singh', 'Amit Sharma', 'Sneha Patel', 'Rohan Verma', 'Kavya Reddy', 'Arjun Mehta', 'Divya Nair'],
    };
    final list = names[cls] ?? ['Student A', 'Student B', 'Student C', 'Student D', 'Student E'];
    return list.asMap().entries.map((e) => AttendanceStudent(
      id: e.key + 1,
      name: e.value,
      rollNo: 'R${(e.key + 1).toString().padLeft(3, '0')}',
    )).toList();
  }

  List<AttendanceStudent> _mockStaff() => [
    AttendanceStudent(id: 101, name: 'Mrs. Rekha Sharma (Principal)', rollNo: 'EMP001'),
    AttendanceStudent(id: 102, name: 'Mr. Anil Gupta (Vice Principal)', rollNo: 'EMP002'),
    AttendanceStudent(id: 103, name: 'Mrs. Sunita Patel', rollNo: 'EMP003'),
    AttendanceStudent(id: 104, name: 'Mr. Rajan Mehta', rollNo: 'EMP004'),
    AttendanceStudent(id: 105, name: 'Mrs. Priya Rao', rollNo: 'EMP005'),
    AttendanceStudent(id: 106, name: 'Mr. Vikram Nair', rollNo: 'EMP006'),
    AttendanceStudent(id: 107, name: 'Ms. Deepa Joshi', rollNo: 'EMP007'),
    AttendanceStudent(id: 108, name: 'Mr. Suresh Kumar', rollNo: 'EMP008'),
  ];
}