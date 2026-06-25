class VehicleModel {
  final int id;
  final String vehicleId;
  final String vehicleNumber;
  final String registrationNumber;
  final String vehicleType; // Bus, Van, Mini Bus
  final String brand;
  final String model;
  final int manufacturingYear;
  final int seatingCapacity;
  final int availableSeats;
  final String fuelType;
  final String insuranceNumber;
  final String insuranceExpiry;
  final String fitnessExpiry;
  final String pollutionExpiry;
  final bool gpsEnabled;
  final bool isAC;
  final String assignedRoute;
  final String assignedDriver;
  final String assignedAttendant;
  final String status; // active, inactive, maintenance
  final String? notes;

  VehicleModel({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.registrationNumber,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.manufacturingYear,
    required this.seatingCapacity,
    required this.availableSeats,
    required this.fuelType,
    required this.insuranceNumber,
    required this.insuranceExpiry,
    required this.fitnessExpiry,
    required this.pollutionExpiry,
    required this.gpsEnabled,
    required this.isAC,
    required this.assignedRoute,
    required this.assignedDriver,
    required this.assignedAttendant,
    required this.status,
    this.notes,
  });

  int get occupiedSeats => seatingCapacity - availableSeats;
}

class RouteModel {
  final int id;
  final String routeName;
  final String routeCode;
  final String startPoint;
  final String destination;
  final double totalDistance;
  final String estimatedDuration;
  final String assignedVehicle;
  final String assignedDriver;
  final String morningSchedule;
  final String afternoonSchedule;
  final String status;
  final List<StopModel> stops;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.routeCode,
    required this.startPoint,
    required this.destination,
    required this.totalDistance,
    required this.estimatedDuration,
    required this.assignedVehicle,
    required this.assignedDriver,
    required this.morningSchedule,
    required this.afternoonSchedule,
    required this.status,
    required this.stops,
  });
}

class StopModel {
  final int id;
  final String stopName;
  final String stopCode;
  final String address;
  final String landmark;
  final String pickupTime;
  final String dropTime;
  final int sequence;

  StopModel({
    required this.id,
    required this.stopName,
    required this.stopCode,
    required this.address,
    required this.landmark,
    required this.pickupTime,
    required this.dropTime,
    required this.sequence,
  });
}

class DriverModel {
  final int id;
  final String name;
  final String employeeId;
  final String phone;
  final String address;
  final String licenseNumber;
  final String licenseExpiry;
  final String experience;
  final String emergencyContact;
  final String assignedVehicle;
  final String status;

  DriverModel({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.phone,
    required this.address,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.experience,
    required this.emergencyContact,
    required this.assignedVehicle,
    required this.status,
  });
}

class StudentTransportModel {
  final int id;
  final String studentName;
  final String admissionNo;
  final String className;
  final String section;
  final String parentPhone;
  final String assignedRoute;
  final String pickupStop;
  final String dropStop;
  final String assignedVehicle;
  final String seatNumber;
  final String startDate;
  final String endDate;
  final double monthlyFee;
  final String feeStatus;

  StudentTransportModel({
    required this.id,
    required this.studentName,
    required this.admissionNo,
    required this.className,
    required this.section,
    required this.parentPhone,
    required this.assignedRoute,
    required this.pickupStop,
    required this.dropStop,
    required this.assignedVehicle,
    required this.seatNumber,
    required this.startDate,
    required this.endDate,
    required this.monthlyFee,
    required this.feeStatus,
  });
}

class MaintenanceModel {
  final int id;
  final String vehicleNumber;
  final String serviceType;
  final String serviceDate;
  final double cost;
  final String workshop;
  final String nextServiceDate;
  final String status;
  final String notes;

  MaintenanceModel({
    required this.id,
    required this.vehicleNumber,
    required this.serviceType,
    required this.serviceDate,
    required this.cost,
    required this.workshop,
    required this.nextServiceDate,
    required this.status,
    required this.notes,
  });
}

