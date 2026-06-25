class HostelModel {
  final int id;
  final String name;
  final String code;
  final String type; // boys, girls, coed
  final String address;
  final int floors;
  final String wardenName;
  final String phone;
  final String email;
  final String emergencyContact;
  final int totalRooms;
  final int occupiedRooms;
  final String status; // active, inactive

  HostelModel({
    required this.id, required this.name, required this.code,
    required this.type, required this.address, required this.floors,
    required this.wardenName, required this.phone, required this.email,
    required this.emergencyContact, required this.totalRooms,
    required this.occupiedRooms, required this.status,
  });

  int get vacantRooms => totalRooms - occupiedRooms;
}

class RoomModel {
  final int id;
  final int hostelId;
  final String hostelName;
  final String roomNumber;
  final int floor;
  final String block;
  final String roomType; // single, double, triple, four, dormitory
  final int capacity;
  final int occupied;
  final bool attachedBathroom;
  final bool isAC;
  final bool isFurnished;
  final double monthlyRent;
  final double securityDeposit;
  final String status; // available, occupied, maintenance, unavailable

  RoomModel({
    required this.id, required this.hostelId, required this.hostelName,
    required this.roomNumber, required this.floor, required this.block,
    required this.roomType, required this.capacity, required this.occupied,
    required this.attachedBathroom, required this.isAC, required this.isFurnished,
    required this.monthlyRent, required this.securityDeposit, required this.status,
  });

  int get available => capacity - occupied;
}

class HostelStudentModel {
  final int id;
  final String studentName;
  final String admissionNo;
  final String className;
  final String section;
  final String hostelName;
  final String roomNumber;
  final String bedNumber;
  final String joiningDate;
  final String expectedLeaving;
  final double monthlyFee;
  final double deposit;
  final String feeStatus; // paid, pending, overdue
  final String status; // active, checkout

  HostelStudentModel({
    required this.id, required this.studentName, required this.admissionNo,
    required this.className, required this.section, required this.hostelName,
    required this.roomNumber, required this.bedNumber, required this.joiningDate,
    required this.expectedLeaving, required this.monthlyFee, required this.deposit,
    required this.feeStatus, required this.status,
  });
}

class ComplaintModel {
  final int id;
  final String studentName;
  final String roomNumber;
  final String title;
  final String description;
  final String priority; // low, medium, high
  // ? FIX: 'accepted' aur 'rejected' status add kiye
  final String status; // pending, accepted, rejected, assigned, resolved
  final String date;
  final String? assignedTo;

  ComplaintModel({
    required this.id, required this.studentName, required this.roomNumber,
    required this.title, required this.description, required this.priority,
    required this.status, required this.date, this.assignedTo,
  });

  // ? FIX: copyWith add kiya taaki provider local update kar sake
  ComplaintModel copyWith({
    String? status,
    String? assignedTo,
  }) {
    return ComplaintModel(
      id: id,
      studentName: studentName,
      roomNumber: roomNumber,
      title: title,
      description: description,
      priority: priority,
      status: status ?? this.status,
      date: date,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}

class VisitorModel {
  final int id;
  final String visitorName;
  final String relation;
  final String phone;
  final String studentName;
  final String entryTime;
  final String? exitTime;
  final String idProof;
  final String status; // approved, pending, rejected

  VisitorModel({
    required this.id, required this.visitorName, required this.relation,
    required this.phone, required this.studentName, required this.entryTime,
    this.exitTime, required this.idProof, required this.status,
  });
}

