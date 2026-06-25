class BookModel {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final String publisher;
  final int publishYear;
  final int totalCopies;
  final int availableCopies;
  final String location; // shelf/rack
  final String status;

  BookModel({
    required this.id, required this.title, required this.author,
    required this.isbn, required this.category, required this.publisher,
    required this.publishYear, required this.totalCopies,
    required this.availableCopies, required this.location, required this.status,
  });

  int get issuedCopies => totalCopies - availableCopies;
}

class BookIssueModel {
  final int id;
  final int bookId;
  final String bookTitle;
  final String bookAuthor;
  final String isbnNumber;
  final int userId;
  final String userName;
  final String userType; // student, staff
  final String admissionOrEmpId;
  final String className; // for students
  final String issueDate;
  final String dueDate;
  final String? returnDate;
  final String status; // issued, returned, overdue
  final double fine;
  final bool finePaid;
  final String? remarks;

  BookIssueModel({
    required this.id, required this.bookId, required this.bookTitle,
    required this.bookAuthor, required this.isbnNumber, required this.userId,
    required this.userName, required this.userType, required this.admissionOrEmpId,
    required this.className, required this.issueDate, required this.dueDate,
    this.returnDate, required this.status, required this.fine,
    required this.finePaid, this.remarks,
  });

  bool get isOverdue {
    if (status == 'returned') return false;
    try {
      final parts = dueDate.split('/');
      final due = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      return DateTime.now().isAfter(due);
    } catch (_) { return false; }
  }

  int get overdueDays {
    if (!isOverdue) return 0;
    try {
      final parts = dueDate.split('/');
      final due = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      return DateTime.now().difference(due).inDays;
    } catch (_) { return 0; }
  }

  double get calculatedFine => overdueDays * 2.0; // Rs 2 per day
}

class LibraryNotificationModel {
  final int id;
  final String userId;
  final String userName;
  final String bookTitle;
  final String message;
  final String type; // overdue, due_soon, fine_reminder
  final String date;
  final bool isRead;

  LibraryNotificationModel({
    required this.id, required this.userId, required this.userName,
    required this.bookTitle, required this.message, required this.type,
    required this.date, required this.isRead,
  });
}

class LibrarySettingsModel {
  final int maxBooksPerStudent;
  final int maxBooksPerStaff;
  final int issueDaysForStudent; // default loan period
  final int issueDaysForStaff;
  final double finePerDay;
  final int dueSoonReminderDays; // send reminder X days before due

  LibrarySettingsModel({
    required this.maxBooksPerStudent, required this.maxBooksPerStaff,
    required this.issueDaysForStudent, required this.issueDaysForStaff,
    required this.finePerDay, required this.dueSoonReminderDays,
  });
}

