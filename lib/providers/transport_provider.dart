import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class VehicleModel {
  final int id;
  final String vehicleNumber;
  final String vehicleType;
  final int seatingCapacity;
  final String driverName;
  final String driverPhone;
  final String driverLicense;
  final String conductorName;
  final String conductorPhone;
  final String assignedRoute;
  final String fuelType;
  final String insuranceExpiry;
  final String fitnessExpiry;
  final String pollutionExpiry;
  final bool gpsEnabled;
  final bool isAC;
  final String status;
  final double currentLat;
  final double currentLng;
  final double currentSpeed;
  final String notes;

  VehicleModel({
    required this.id, required this.vehicleNumber, required this.vehicleType,
    required this.seatingCapacity, required this.driverName,
    required this.driverPhone, required this.driverLicense,
    required this.conductorName, required this.conductorPhone,
    required this.assignedRoute, required this.fuelType,
    required this.insuranceExpiry, required this.fitnessExpiry,
    required this.pollutionExpiry, required this.gpsEnabled,
    required this.isAC, required this.status,
    required this.currentLat, required this.currentLng,
    required this.currentSpeed, required this.notes,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> j) => VehicleModel(
    id: j['id'] ?? 0,
    vehicleNumber: j['vehicle_number'] ?? '',
    vehicleType: j['vehicle_type'] ?? 'Bus',
    seatingCapacity: j['seating_capacity'] ?? 40,
    driverName: j['driver_name'] ?? '',
    driverPhone: j['driver_phone'] ?? '',
    driverLicense: j['driver_license'] ?? '',
    conductorName: j['conductor_name'] ?? '',
    conductorPhone: j['conductor_phone'] ?? '',
    assignedRoute: j['assigned_route'] ?? '',
    fuelType: j['fuel_type'] ?? 'Diesel',
    insuranceExpiry: j['insurance_expiry'] ?? '',
    fitnessExpiry: j['fitness_expiry'] ?? '',
    pollutionExpiry: j['pollution_expiry'] ?? '',
    gpsEnabled: j['gps_enabled'] ?? true,
    isAC: j['is_ac'] ?? false,
    status: j['status'] ?? 'active',
    currentLat: (j['current_lat'] ?? 28.6139).toDouble(),
    currentLng: (j['current_lng'] ?? 77.2090).toDouble(),
    currentSpeed: (j['current_speed'] ?? 0).toDouble(),
    notes: j['notes'] ?? '',
  );

  Map<String, dynamic> toJson() => {
        'vehicle_number': vehicleNumber, 'vehicle_type': vehicleType,
        'seating_capacity': seatingCapacity, 'driver_name': driverName,
        'driver_phone': driverPhone, 'driver_license': driverLicense,
        'conductor_name': conductorName, 'conductor_phone': conductorPhone,
        'assigned_route': assignedRoute, 'fuel_type': fuelType,
        'insurance_expiry': insuranceExpiry, 'fitness_expiry': fitnessExpiry,
        'pollution_expiry': pollutionExpiry, 'gps_enabled': gpsEnabled,
        'is_ac': isAC, 'status': status, 'notes': notes,
  };
}

class RouteModel {
  final int id;
  final String routeName;
  final String routeCode;
  final String startPoint;
  final String endPoint;
  final double totalDistance;
  final String duration;
  final String morningTime;
  final String eveningTime;
  final int assignedVehicle;
  final double monthlyFee;
  final String stops;
  final String status;

  RouteModel({
    required this.id, required this.routeName, required this.routeCode,
    required this.startPoint, required this.endPoint,
    required this.totalDistance, required this.duration,
    required this.morningTime, required this.eveningTime,
    required this.assignedVehicle, required this.monthlyFee,
    required this.stops, required this.status,
  });

  factory RouteModel.fromJson(Map<String, dynamic> j) => RouteModel(
    id: j['id'] ?? 0,
    routeName: j['route_name'] ?? '',
    routeCode: j['route_code'] ?? '',
    startPoint: j['start_point'] ?? '',
    endPoint: j['end_point'] ?? '',
    totalDistance: (j['total_distance'] ?? 0).toDouble(),
    duration: j['duration'] ?? '',
    morningTime: j['morning_time'] ?? '',
    eveningTime: j['evening_time'] ?? '',
    assignedVehicle: j['assigned_vehicle'] ?? 0,
    monthlyFee: (j['monthly_fee'] ?? 0).toDouble(),
    stops: j['stops'] ?? '',
    status: j['status'] ?? 'active',
  );
}

class StudentTransportModel {
  final int id;
  final int studentId;
  final String studentName;
  final int vehicleId;
  final int routeId;
  final String pickupStop;
  final String dropStop;
  final double monthlyFee;
  final String status;
  final String startDate;

  StudentTransportModel({
    required this.id, required this.studentId, required this.studentName,
    required this.vehicleId, required this.routeId,
    required this.pickupStop, required this.dropStop,
    required this.monthlyFee, required this.status, required this.startDate,
  });

  factory StudentTransportModel.fromJson(Map<String, dynamic> j) =>
    StudentTransportModel(
      id: j['id'] ?? 0,
      studentId: j['student_id'] ?? 0,
      studentName: j['student_name'] ?? '',
      vehicleId: j['vehicle_id'] ?? 0,
      routeId: j['route_id'] ?? 0,
      pickupStop: j['pickup_stop'] ?? '',
      dropStop: j['drop_stop'] ?? '',
      monthlyFee: (j['monthly_fee'] ?? 0).toDouble(),
      status: j['status'] ?? 'active',
      startDate: j['start_date'] ?? '',
    );
}

class TransportFeeModel {
  final int id;
  final int studentId;
  final String studentName;
  final int vehicleId;
  final int routeId;
  final double amount;
  final String month;
  final String status;
  final String paidDate;

  TransportFeeModel({
    required this.id, required this.studentId, required this.studentName,
    required this.vehicleId, required this.routeId, required this.amount,
    required this.month, required this.status, required this.paidDate,
  });

  factory TransportFeeModel.fromJson(Map<String, dynamic> j) =>
    TransportFeeModel(
      id: j['id'] ?? 0,
      studentId: j['student_id'] ?? 0,
      studentName: j['student_name'] ?? '',
      vehicleId: j['vehicle_id'] ?? 0,
      routeId: j['route_id'] ?? 0,
      amount: (j['amount'] ?? 0).toDouble(),
      month: j['month'] ?? '',
      status: j['status'] ?? 'pending',
      paidDate: j['paid_date'] ?? '',
    );
}

class TransportProvider extends ChangeNotifier {
  List<VehicleModel> _vehicles = [];
  List<RouteModel> _routes = [];
  List<StudentTransportModel> _students = [];
  List<TransportFeeModel> _fees = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  List<RouteModel> get routes => _routes;
  List<StudentTransportModel> get students => _students;
  List<TransportFeeModel> get fees => _fees;
  bool get isLoading => _isLoading;

  int get totalVehicles => _vehicles.length;
  int get activeVehicles => _vehicles.where((v) => v.status == 'active').length;
  int get totalRoutes => _routes.length;
  int get studentsWithTransport => _students.length;
  int get maintenanceCount => _vehicles.where((v) => v.status == "maintenance").length;
  double get totalFeeCollected => _fees.where((f) => f.status == "paid").fold(0.0, (s, f) => s + f.amount);
  double get totalFeePending => _fees.where((f) => f.status == "pending").fold(0.0, (s, f) => s + f.amount);

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    await Future.wait([fetchVehicles(), fetchRoutes(),
      fetchStudents(), fetchFees()]);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVehicles() async {
    try {
      final r = await apiService.get('/transport/vehicles');
      final data = r['data'] as List? ?? [];
      _vehicles = data.map((j) => VehicleModel.fromJson(j)).toList();
      notifyListeners();
    } catch (e) { debugPrint('fetchVehicles: $e'); }
  }

  Future<void> fetchRoutes() async {
    try {
      final r = await apiService.get('/transport/routes');
      final data = r['data'] as List? ?? [];
      _routes = data.map((j) => RouteModel.fromJson(j)).toList();
      notifyListeners();
    } catch (e) { debugPrint('fetchRoutes: $e'); }
  }

  Future<void> fetchStudents() async {
    try {
      final r = await apiService.get('/transport/students');
      final data = r['data'] as List? ?? [];
      _students = data.map((j) => StudentTransportModel.fromJson(j)).toList();
      notifyListeners();
    } catch (e) { debugPrint('fetchStudents: $e'); }
  }

  Future<void> fetchFees() async {
    try {
      final r = await apiService.get('/transport/fees');
      final data = r['data'] as List? ?? [];
      _fees = data.map((j) => TransportFeeModel.fromJson(j)).toList();
      notifyListeners();
    } catch (e) { debugPrint('fetchFees: $e'); }
  }

  Future<bool> addVehicle(Map<String, dynamic> data) async {
    try {
      await apiService.post('/transport/vehicles', data);
      await fetchVehicles();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> updateVehicle(int id, Map<String, dynamic> data) async {
    try {
      await apiService.put('/transport/vehicles/$id', data);
      await fetchVehicles();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> deleteVehicle(int id) async {
    try {
      await apiService.delete('/transport/vehicles/$id');
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> addRoute(Map<String, dynamic> data) async {
    try {
      await apiService.post('/transport/routes', data);
      await fetchRoutes();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> deleteRoute(int id) async {
    try {
      await apiService.delete('/transport/routes/$id');
      _routes.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> assignTransport(Map<String, dynamic> data) async {
    try {
      await apiService.post('/transport/students', data);
      await fetchStudents();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> createFee(Map<String, dynamic> data) async {
    try {
      await apiService.post('/transport/fees', data);
      await fetchFees();
      return true;
    } catch (e) { return false; }
  }

  Future<bool> updateFeeStatus(int id, String status) async {
    try {
      await apiService.put('/transport/fees/$id/status', {
        'status': status,
        'paid_date': status == 'paid'
          ? '${DateTime.now().day.toString().padLeft(2,'0')}/${DateTime.now().month.toString().padLeft(2,'0')}/${DateTime.now().year}'
          : '',
      });
      await fetchFees();
      return true;
    } catch (e) { return false; }
  }
}



