import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/hostel_model.dart';

class HostelProvider extends ChangeNotifier {
  List<HostelModel> _hostels = [];
  List<RoomModel> _rooms = [];
  List<HostelStudentModel> _students = [];
  List<ComplaintModel> _complaints = [];
  List<VisitorModel> _visitors = [];
  bool _isLoading = false;
  bool _complaintsLoading = false;
  String _searchQuery = '';
  String _filterType = 'All';

  // ??? FIX: isAdmin track karo
  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  // AuthProvider login ke baad ye call karo
  void setRole(String role) {
    _isAdmin = role == 'admin';
    notifyListeners();
  }

  List<HostelModel> get hostels => _hostels;
  List<RoomModel> get rooms {
    var list = _rooms;
    if (_filterType != 'All') list = list.where((r) => r.status == _filterType).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((r) =>
        r.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.block.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }
  List<HostelStudentModel> get students => _students;
  List<ComplaintModel> get complaints => _complaints;
  List<VisitorModel> get visitors => _visitors;
  bool get isLoading => _isLoading;
  bool get complaintsLoading => _complaintsLoading;

  // Dashboard stats
  int get totalHostels => _hostels.length;
  int get totalRooms => _rooms.length;
  int get occupiedRooms => _rooms.where((r) => r.status == 'occupied').length;
  int get vacantRooms => _rooms.where((r) => r.status == 'available').length;
  int get maintenanceRooms => _rooms.where((r) => r.status == 'maintenance').length;
  int get totalBeds => _rooms.fold(0, (sum, r) => sum + r.capacity);
  int get occupiedBeds => _rooms.fold(0, (sum, r) => sum + r.occupied);
  int get availableBeds => totalBeds - occupiedBeds;
  int get boysHostels => _hostels.where((h) => h.type == 'boys').length;
  int get girlsHostels => _hostels.where((h) => h.type == 'girls').length;
  int get totalStudents => _students.where((s) => s.status == 'active').length;
  double get pendingFees => _students
    .where((s) => s.feeStatus == 'pending' || s.feeStatus == 'overdue')
    .fold(0.0, (sum, s) => sum + s.monthlyFee);
  int get pendingComplaints => _complaints.where((c) => c.status == 'pending').length;

  // ============================================================
  // FETCH ALL
  // ============================================================
  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Hostels
      final hostelRes = await apiService.get('/hostel');
      final hostelData = hostelRes['data'] as List? ?? [];
      _hostels = hostelData.map((j) => HostelModel(
        id: j['id'] ?? 0,
        name: j['name'] ?? '',
        code: j['code'] ?? '',
        type: j['type'] ?? '',
        address: j['address'] ?? '',
        floors: j['floors'] ?? 0,
        wardenName: j['warden_name'] ?? '',
        phone: j['phone'] ?? '',
        email: j['email'] ?? '',
        emergencyContact: j['emergency_contact'] ?? '',
        totalRooms: j['total_rooms'] ?? 0,
        occupiedRooms: j['occupied_rooms'] ?? 0,
        status: j['status'] ?? 'active',
      )).toList();

      // 2. Rooms
      final roomRes = await apiService.get('/hostel/rooms');
      final roomData = roomRes['data'] as List? ?? [];
      _rooms = roomData.map((j) {
        final hostelId = j['hostel_id'] ?? 0;
        final hostelName = _hostels
            .firstWhere((h) => h.id == hostelId,
                orElse: () => HostelModel(
                    id: 0, name: '', code: '', type: '', address: '',
                    floors: 0, wardenName: '', phone: '', email: '',
                    emergencyContact: '', totalRooms: 0, occupiedRooms: 0,
                    status: ''))
            .name;
        return RoomModel(
          id: j['id'] ?? 0,
          hostelId: hostelId,
          hostelName: hostelName,
          roomNumber: j['room_number'] ?? '',
          floor: j['floor'] ?? 0,
          block: j['block'] ?? '',
          roomType: j['room_type'] ?? '',
          capacity: j['capacity'] ?? 0,
          occupied: j['occupied'] ?? 0,
          attachedBathroom: j['attached_bathroom'] ?? false,
          isAC: j['is_ac'] ?? false,
          isFurnished: j['is_furnished'] ?? false,
          monthlyRent: (j['monthly_rent'] ?? 0).toDouble(),
          securityDeposit: (j['security_deposit'] ?? 0).toDouble(),
          status: j['status'] ?? 'available',
        );
      }).toList();

      // 3. Hostel Students
      final studentRes = await apiService.get('/students');
      final studentData = studentRes['data'] as List? ?? [];

      final hostelStudentRes = await apiService.get('/hostel/students');
      final hostelStudentData = hostelStudentRes['data'] as List? ?? [];

      _students = hostelStudentData.map((j) {
        final studentId = j['student_id'] ?? 0;
        final hostelId = j['hostel_id'] ?? 0;
        final roomId = j['room_id'] ?? 0;

        final matchedStudent = studentData.firstWhere(
          (s) => s['id'] == studentId,
          orElse: () => null,
        );
        final matchedHostel = _hostels.firstWhere(
          (h) => h.id == hostelId,
          orElse: () => HostelModel(
              id: 0, name: '-', code: '', type: '', address: '',
              floors: 0, wardenName: '', phone: '', email: '',
              emergencyContact: '', totalRooms: 0, occupiedRooms: 0,
              status: ''),
        );
        final matchedRoom = _rooms.firstWhere(
          (r) => r.id == roomId,
          orElse: () => RoomModel(
              id: 0, hostelId: 0, hostelName: '', roomNumber: '-',
              floor: 0, block: '', roomType: '', capacity: 0, occupied: 0,
              attachedBathroom: false, isAC: false, isFurnished: false,
              monthlyRent: 0, securityDeposit: 0, status: ''),
        );

        return HostelStudentModel(
          id: j['id'] ?? 0,
          studentName: matchedStudent != null ? (matchedStudent['name'] ?? 'Unknown') : 'Unknown',
          admissionNo: matchedStudent != null ? (matchedStudent['admission_no'] ?? '') : '',
          className: matchedStudent != null ? (matchedStudent['class_name'] ?? '') : '',
          section: matchedStudent != null ? (matchedStudent['section'] ?? '') : '',
          hostelName: matchedHostel.name,
          roomNumber: matchedRoom.roomNumber,
          bedNumber: j['bed_number'] ?? '',
          joiningDate: j['joining_date'] ?? '',
          expectedLeaving: j['expected_leaving'] ?? '',
          monthlyFee: (j['monthly_fee'] ?? 0).toDouble(),
          deposit: (j['deposit'] ?? 0).toDouble(),
          feeStatus: j['fee_status'] ?? 'pending',
          status: j['status'] ?? 'active',
        );
      }).toList();

      _visitors = [];
    } catch (e) {
      debugPrint('HostelProvider.fetchAll error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // COMPLAINTS - fetch (admin: saari complaints)
  // ============================================================
  Future<void> fetchComplaints() async {
    _complaintsLoading = true;
    notifyListeners();
    try {
      final res = await apiService.get('/hostel/complaints');
      final data = res['data'] as List? ?? [];
      _complaints = data.map((j) => ComplaintModel(
        id: j['id'] ?? 0,
        studentName: j['student_name'] ?? '',
        roomNumber: j['room_number'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        priority: j['priority'] ?? 'medium',
        status: j['status'] ?? 'pending',
        date: j['created_at'] != null
            ? j['created_at'].toString().substring(0, 10)
            : '',
        assignedTo: j['assigned_to'],
      )).toList();
    } catch (e) {
      debugPrint('fetchComplaints error: $e');
    }
    _complaintsLoading = false;
    notifyListeners();
  }

  // ??? FIX: Student ke liye sirf apni complaints fetch karo (latest upar)
  Future<void> fetchMyComplaints() async {
    _complaintsLoading = true;
    notifyListeners();
    try {
      // GET /api/v1/hostel/complaints/my
      // Backend already "ORDER BY created_at DESC" karta hai
      final res = await apiService.get('/hostel/complaints/my');
      final data = res['data'] as List? ?? [];
      _complaints = data.map((j) => ComplaintModel(
        id: j['id'] ?? 0,
        studentName: j['student_name'] ?? '',
        roomNumber: j['room_number'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        priority: j['priority'] ?? 'medium',
        status: j['status'] ?? 'pending',
        date: j['created_at'] != null
            ? j['created_at'].toString().substring(0, 10)
            : '',
        assignedTo: j['assigned_to'],
      )).toList();
    } catch (e) {
      debugPrint('fetchMyComplaints error: $e');
    }
    _complaintsLoading = false;
    notifyListeners();
  }

  // ??? FIX: Student complaint submit kare + list turant refresh ho
  Future<bool> submitComplaint({
    required String title,
    required String description,
    required String priority,
    String roomNumber = '',
  }) async {
    try {
      await apiService.post('/hostel/complaints', {
        'title': title,
        'description': description,
        'priority': priority,
        'room_number': roomNumber,
      });
      // Submit ke baad apni complaints dobara fetch karo ??? naya complaint upar aayega
      await fetchMyComplaints();
      return true;
    } catch (e) {
      debugPrint('submitComplaint error: $e');
      return false;
    }
  }

  // ??? FIX: Admin complaint ACCEPT kare
  Future<bool> acceptComplaint(int id) async {
    try {
      await apiService.put('/hostel/complaints/$id/accept', {});
      // Local list update ??? fast response, no extra API call
      final idx = _complaints.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _complaints[idx] = _complaints[idx].copyWith(status: 'accepted');
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('acceptComplaint error: $e');
      return false;
    }
  }

  // ??? FIX: Admin complaint REJECT kare
  Future<bool> rejectComplaint(int id) async {
    try {
      await apiService.put('/hostel/complaints/$id/reject', {});
      // Local list update
      final idx = _complaints.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _complaints[idx] = _complaints[idx].copyWith(status: 'rejected');
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('rejectComplaint error: $e');
      return false;
    }
  }

  // ============================================================
  // COMPLAINTS - assign (admin)
  // ============================================================
 Future<bool> assignComplaint(int id, String assignedTo) async {
    final idx = _complaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _complaints[idx] = _complaints[idx].copyWith(
        assignedTo: assignedTo, status: 'assigned');
      notifyListeners();
      return true;
    }
    return false;
  }
  // ============================================================
  // COMPLAINTS - resolve (admin)
  // ============================================================
  Future<bool> resolveComplaint(int id) async {
    try {
      await apiService.put('/hostel/complaints/$id/resolve', {});
      // Local update
      final idx = _complaints.indexWhere((c) => c.id == id);
      if (idx != -1) {
        _complaints[idx] = _complaints[idx].copyWith(status: 'resolved');
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('resolveComplaint error: $e');
      return false;
    }
  }

  // ============================================================
  // CREATE HOSTEL
  // ============================================================
  Future<bool> addHostel(HostelModel hostel) async {
    try {
      await apiService.post('/hostel', {
        'name': hostel.name,
        'code': hostel.code,
        'type': hostel.type,
        'address': hostel.address,
        'floors': hostel.floors,
        'warden_name': hostel.wardenName,
        'phone': hostel.phone,
        'email': hostel.email,
        'emergency_contact': hostel.emergencyContact,
      });
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint('addHostel error: $e');
      return false;
    }
  }

  Future<bool> deleteHostel(int id) async {
    try {
      await apiService.delete('/hostel/$id');
      _hostels.removeWhere((h) => h.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('deleteHostel error: $e');
      return false;
    }
  }

  // ============================================================
  // CREATE ROOM
  // ============================================================
  Future<bool> addRoom(RoomModel room) async {
    try {
      await apiService.post('/hostel/rooms', {
        'hostel_id': room.hostelId,
        'room_number': room.roomNumber,
        'floor': room.floor,
        'block': room.block,
        'room_type': room.roomType,
        'capacity': room.capacity,
        'attached_bathroom': room.attachedBathroom,
        'is_ac': room.isAC,
        'is_furnished': room.isFurnished,
        'monthly_rent': room.monthlyRent,
        'security_deposit': room.securityDeposit,
      });
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint('addRoom error: $e');
      return false;
    }
  }

  // ============================================================
  // ALLOCATE ROOM
  // ============================================================
  Future<bool> allocateRoom({
    required int studentId,
    required int hostelId,
    required int roomId,
    required String bedNumber,
    required String joiningDate,
    String expectedLeaving = '',
    required double monthlyFee,
    double deposit = 0,
  }) async {
    try {
      await apiService.post('/hostel/allocate', {
        'student_id': studentId,
        'hostel_id': hostelId,
        'room_id': roomId,
        'bed_number': bedNumber,
        'joining_date': joiningDate,
        'expected_leaving': expectedLeaving,
        'monthly_fee': monthlyFee,
        'deposit': deposit,
      });
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint('allocateRoom error: $e');
      return false;
    }
  }

  // ============================================================
  // TRANSFER
  // ============================================================
  Future<bool> transferStudent({
    required int hostelStudentId,
    required int hostelId,
    required int roomId,
    required String bedNumber,
  }) async {
    try {
      await apiService.put('/hostel/students/$hostelStudentId/transfer', {
        'hostel_id': hostelId,
        'room_id': roomId,
        'bed_number': bedNumber,
      });
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint('transferStudent error: $e');
      return false;
    }
  }

  // ============================================================
  // CHECKOUT
  // ============================================================
  Future<bool> checkoutStudent(int hostelStudentId) async {
    try {
      await apiService.put('/hostel/students/$hostelStudentId/checkout', {});
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint('checkoutStudent error: $e');
      return false;
    }
  }

  // ============================================================
  // FEE STATUS UPDATE
  // ============================================================
  Future<bool> updateFeeStatus(int hostelStudentId, String feeStatus) async {
    try {
      await apiService.put('/hostel/fees/$hostelStudentId', {
        'fee_status': feeStatus,
      });
      await fetchAll();
      return true;
    } catch (e) {
      debugPrint('updateFeeStatus error: $e');
      return false;
    }
  }

  // ============================================================
  // ATTENDANCE - fetch
  // ============================================================
  Future<List<Map<String, dynamic>>> fetchAttendance(String date) async {
    try {
      final res = await apiService.get('/hostel/attendance?date=$date');
      final data = res['data'] as List? ?? [];
      return data.map((row) {
        final hostelStudentId = row['hostel_student_id'];
        final matched = _students.firstWhere(
          (s) => s.id == hostelStudentId,
          orElse: () => HostelStudentModel(
            id: hostelStudentId ?? 0, studentName: 'Unknown', admissionNo: '',
            className: '', section: '', hostelName: '', roomNumber: '-',
            bedNumber: '', joiningDate: '', expectedLeaving: '',
            monthlyFee: 0, deposit: 0, feeStatus: 'pending', status: 'active',
          ),
        );
        return {
        'hostel_student_id': hostelStudentId,
        'name': matched.studentName,
        'room': matched.roomNumber,
        'status': row['status'] == '' || row['status'] == null
              ? 'present'
              : (row['status'] == 'leave' ? 'on_leave' : row['status']),
        };
      }).toList();
    } catch (e) {
      debugPrint('fetchAttendance error: $e');
      return [];
    }
  }

  // ============================================================
  // ATTENDANCE - save
  // ============================================================
  Future<bool> saveAttendance(String date, List<Map<String, dynamic>> records) async {
    try {
      await apiService.post('/hostel/attendance', {
        'date': date,
        'records': records.map((r) => {
        'hostel_student_id': r['hostel_student_id'],
        'status': r['status'] == 'on_leave' ? 'leave' : r['status'],
        }).toList(),
      });
      return true;
    } catch (e) {
      debugPrint('saveAttendance error: $e');
      return false;
    }
  }

  
  Future<bool> addComplaint({
    required String title, required String description,
    required String category, required String priority,
    required String studentName, required String roomNumber,
  }) async {
    try {
      await apiService.post('/complaints', {
        'title': title, 'description': description,
        'category': category, 'priority': priority,
        'student_name': studentName, 'room_number': roomNumber,
        'status': 'pending',
      });
      await fetchComplaints();
      return true;
    } catch (e) { return false; }
  }
  Future<bool> updateComplaintStatus(int id, String status) async {
    final idx = _complaints.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _complaints[idx] = _complaints[idx].copyWith(status: status);
      notifyListeners();
      return true;
    }
    return false;
  }
  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setFilter(String f) { _filterType = f; notifyListeners(); }
}


