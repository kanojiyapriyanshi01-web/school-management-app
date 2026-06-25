import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';

class ExamModel {
  final int id;
  final String name;
  final int classId;
  final String className;
  final String section;
  final String examType;
  final String academicYear;
  final String startDate;
  final String endDate;
  final String description;
  final String status;

  ExamModel({
    required this.id, required this.name, required this.classId,
    required this.className, this.section = 'A',
    this.examType = 'Unit Test', this.academicYear = '2025-26',
    required this.startDate, required this.endDate,
    this.description = '', this.status = 'draft',
  });

  factory ExamModel.fromJson(Map<String, dynamic> j) => ExamModel(
    id: j['id'] ?? 0,
    name: j['exam_name'] ?? j['name'] ?? '',
    classId: j['class_id'] ?? 0,
    className: j['class_name'] ?? '',
    section: j['section'] ?? 'A',
    examType: j['exam_type'] ?? 'Unit Test',
    academicYear: j['academic_year'] ?? '2025-26',
    startDate: j['start_date'] ?? '',
    endDate: j['end_date'] ?? '',
    description: j['description'] ?? '',
    status: j['status'] ?? 'draft',
  );
}

class MarkModel {
  final int id;
  final int studentId;
  final int examId;
  final String subject;
  final double marksObtained;
  final double maxMarks;
  final String grade;

  MarkModel({
    required this.id, required this.studentId, required this.examId,
    required this.subject, required this.marksObtained,
    required this.maxMarks, required this.grade,
  });

  double get percentage => maxMarks > 0 ? (marksObtained / maxMarks) * 100 : 0;
}

class ExamProvider extends ChangeNotifier {
  List<ExamModel> _exams = [];
  List<MarkModel> _marks = [];
  bool _isLoading = false;

  List<ExamModel> get exams => _exams;
  List<MarkModel> get marks => _marks;
  bool get isLoading => _isLoading;

  // ?? Computed getters (must be INSIDE the class) ????????
  int get upcomingExams  => _exams.where((e) => e.status == 'published').length;
  int get ongoingExams   => _exams.where((e) => e.status == 'ongoing').length;
  int get completedExams => _exams.where((e) => e.status == 'completed').length;

  double get passPercentage {
    if (_marks.isEmpty) return 0;
    final passed = _marks.where((m) => m.percentage >= 35).length;
    return (passed / _marks.length * 100);
  }

  double get avgScore {
    if (_marks.isEmpty) return 0;
    final total = _marks.fold<double>(0, (sum, m) => sum + m.percentage);
    return total / _marks.length;
  }
  // ?????????????

  Future<void> fetchExams() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.get('/exams');
      final data = response['data'] as List? ?? [];
      _exams = data.map((j) => ExamModel.fromJson(j)).toList();
    } catch (e) {
      _exams = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createExam({
    required String name,
    required int classId,
    required String startDate,
    required String endDate,
    String examType = 'Unit Test',
    String academicYear = '2025-26',
    String className = '',
    String section = 'A',
    String description = '',
    String status = 'draft',
  }) async {
    try {
      final response = await apiService.post('/exams', {
        'exam_name': name,
        'class_id': classId,
        'start_date': startDate,
        'end_date': endDate,
        'exam_type': examType,
        'academic_year': academicYear,
        'class_name': className,
        'section': section,
        'description': description,
        'status': status,
      });
      final exam = ExamModel.fromJson(response['data']);
      _exams.insert(0, exam);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchMarks({int? examId, int? studentId}) async {
    try {
      String endpoint = '/marks';
      final params = <String>[];
      if (examId != null) params.add('exam_id=$examId');
      if (studentId != null) params.add('student_id=$studentId');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';
      final response = await apiService.get(endpoint);
      final data = response['data'] as List? ?? [];
      _marks = data.map((j) => MarkModel(
        id: j['id'] ?? 0,
        studentId: j['student_id'] ?? 0,
        examId: j['exam_id'] ?? 0,
        subject: j['subject'] ?? '',
        marksObtained: (j['marks_obtained'] ?? 0).toDouble(),
        maxMarks: (j['max_marks'] ?? 100).toDouble(),
        grade: j['grade'] ?? '',
      )).toList();
      notifyListeners();
    } catch (e) {
      _marks = [];
    }
  }

 Future<bool> updateExamStatus(int examId, String status) async {
  try {
    await apiService.put('/exams/$examId', {'status': status});
    final idx = _exams.indexWhere((e) => e.id == examId);
    if (idx != -1) {
      _exams[idx] = ExamModel(
        id: _exams[idx].id,
        name: _exams[idx].name,
        classId: _exams[idx].classId,
        className: _exams[idx].className,
        section: _exams[idx].section,
        examType: _exams[idx].examType,
        academicYear: _exams[idx].academicYear,
        startDate: _exams[idx].startDate,
        endDate: _exams[idx].endDate,
        description: _exams[idx].description,
        status: status,
      );
      notifyListeners();
    }
    return true;
  } catch (e) {
    return false;
  }
}
}

