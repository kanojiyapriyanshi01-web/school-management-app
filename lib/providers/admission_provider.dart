import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AdmissionModel {
  final int id;
  final String studentName;
  final String dob;
  final String gender;
  final String applyingClass;
  final String academicYear;
  final String fatherName;
  final String motherName;
  final String parentPhone;
  final String email;
  final String address;
  final String previousSchool;
  final String status;
  final String studentId;
  final String remarks;
  final List<String> documents;

  AdmissionModel({
    required this.id, required this.studentName, required this.dob,
    required this.gender, required this.applyingClass, required this.academicYear,
    required this.fatherName, required this.motherName, required this.parentPhone,
    required this.email, required this.address, required this.previousSchool,
    required this.status, required this.studentId, required this.remarks,
    this.documents = const [],
  });

  factory AdmissionModel.fromJson(Map<String, dynamic> j) => AdmissionModel(
    id: j['id'] ?? 0,
    studentName: j['student_name'] ?? '',
    dob: j['dob'] ?? '',
    gender: j['gender'] ?? '',
    applyingClass: j['applying_class'] ?? '',
    academicYear: j['academic_year'] ?? '',
    fatherName: j['father_name'] ?? '',
    motherName: j['mother_name'] ?? '',
    parentPhone: j['parent_phone'] ?? '',
    email: j['email'] ?? '',
    address: j['address'] ?? '',
    previousSchool: j['previous_school'] ?? '',
    status: j['status'] ?? 'pending',
    studentId: j['student_id'] ?? '',
    remarks: j['remarks'] ?? '',
    documents: [],
  );
}

class AdmissionProvider extends ChangeNotifier {
  List<AdmissionModel> _admissions = [];
  bool _isLoading = false;

  List<AdmissionModel> get admissions => _admissions;
  bool get isLoading => _isLoading;
  int get total => _admissions.length;
  int get pending => _admissions.where((a) => a.status == 'pending').length;
  int get approved => _admissions.where((a) => a.status == 'approved').length;
  int get rejected => _admissions.where((a) => a.status == 'rejected').length;

  Future<void> fetchAdmissions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await apiService.get('/admissions');
      _admissions = (response['data'] as List)
        .map((j) => AdmissionModel.fromJson(j)).toList();
    } catch (e) {
      _admissions = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitAdmission({
    required String studentName, required String dob, required String gender,
    required String applyingClass, required String academicYear,
    required String fatherName, required String motherName,
    required String parentPhone, required String email,
    required String address, required String previousSchool,
    List<String> documents = const [],
  }) async {
    try {
      final response = await apiService.post('/admissions', {
        'student_name': studentName, 'dob': dob, 'gender': gender,
        'applying_class': applyingClass, 'academic_year': academicYear,
        'father_name': fatherName, 'mother_name': motherName,
        'parent_phone': parentPhone, 'email': email,
        'address': address, 'previous_school': previousSchool,
      });
      final a = AdmissionModel.fromJson(response['data']);
      _admissions.insert(0, a);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(int id, String status, {String remarks = ''}) async {
    try {
      await apiService.put('/admissions/$id/status', {
        'status': status, 'remarks': remarks,
      });
      await fetchAdmissions();
      return true;
    } catch (e) {
      // Demo mode - update locally
      final idx = _admissions.indexWhere((a) => a.id == id);
      if (idx != -1) {
        final old = _admissions[idx];
        final newStudentId = status == 'approved'
          ? 'STU${(1000 + idx + 1).toString()}'
          : old.studentId;
        _admissions[idx] = AdmissionModel(
          id: old.id, studentName: old.studentName, dob: old.dob,
          gender: old.gender, applyingClass: old.applyingClass,
          academicYear: old.academicYear, fatherName: old.fatherName,
          motherName: old.motherName, parentPhone: old.parentPhone,
          email: old.email, address: old.address,
          previousSchool: old.previousSchool, status: status,
          studentId: newStudentId, remarks: remarks,
        );
        notifyListeners();
      }
      return true;
    }
  }
}


