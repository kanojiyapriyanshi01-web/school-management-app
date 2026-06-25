import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/library_model.dart';

class LibraryProvider extends ChangeNotifier {
  List<BookModel> _books = [];
  List<BookIssueModel> _issues = [];
  List<LibraryNotificationModel> _notifications = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterCategory = 'All';

  LibrarySettingsModel settings = LibrarySettingsModel(
    maxBooksPerStudent: 2,
    maxBooksPerStaff: 4,
    issueDaysForStudent: 14,
    issueDaysForStaff: 30,
    finePerDay: 2.0,
    dueSoonReminderDays: 2,
  );

  List<BookModel> get books {
    var list = _books;
    if (_filterCategory != 'All') {
      list = list.where((b) => b.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) =>
        b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        b.isbn.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<BookIssueModel> get issues => _issues;
  List<BookIssueModel> get activeIssues => _issues.where((i) => i.status == 'issued').toList();
  List<BookIssueModel> get overdueIssues => _issues.where((i) => i.isOverdue).toList();
  List<LibraryNotificationModel> get notifications => _notifications;
  List<LibraryNotificationModel> get unreadNotifications =>
    _notifications.where((n) => !n.isRead).toList();
  bool get isLoading => _isLoading;

  int get totalBooks => _books.fold(0, (sum, b) => sum + b.totalCopies);
  int get issuedBooks => _books.fold(0, (sum, b) => sum + b.issuedCopies);
  int get availableBooks => _books.fold(0, (sum, b) => sum + b.availableCopies);
  int get overdueCount => overdueIssues.length;
  double get totalFineCollected => _issues.where((i) => i.finePaid).fold(0.0, (sum, i) => sum + i.fine);
  double get totalFinePending => _issues.where((i) => i.isOverdue && !i.finePaid).fold(0.0, (sum, i) => sum + i.calculatedFine);

  List<BookIssueModel> getIssuesForUser(String userId) =>
    _issues.where((i) => i.admissionOrEmpId == userId).toList();
  List<BookIssueModel> getActiveIssuesForUser(String userId) =>
    _issues.where((i) => i.admissionOrEmpId == userId && i.status == 'issued').toList();

  Future<void> fetchAll() async {
    _isLoading = true;
    notifyListeners();
    await fetchBooks();
    await fetchIssues();
    _generateNotifications();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    try {
      final response = await apiService.get('/books');
      final data = response['data'] as List? ?? [];
      _books = data.map((j) => BookModel(
        id: j['id'] ?? 0,
        title: j['title'] ?? '',
        author: j['author'] ?? '',
        isbn: j['isbn'] ?? '',
        category: j['category'] ?? 'General',
        publisher: j['publisher'] ?? '',
        publishYear: j['publish_year'] ?? DateTime.now().year,
        totalCopies: j['total_copies'] ?? 0,
        availableCopies: j['available_copies'] ?? 0,
        location: j['location'] ?? '',
        status: j['status'] ?? 'active',
      )).toList();
    } catch (e) {
      _books = [];
    }
  }

  Future<void> fetchIssues() async {
    try {
      final response = await apiService.get('/books/my');
      final data = response['data'] as List? ?? [];
      _issues = data.map((j) {
        final bookId = j['book_id'] ?? 0;
        final book = _books.firstWhere((b) => b.id == bookId,
          orElse: () => BookModel(id: 0, title: 'Unknown Book',
            author: '', isbn: '', category: '', publisher: '',
            publishYear: 0, totalCopies: 0, availableCopies: 0,
            location: '', status: ''));
        return BookIssueModel(
          id: j['id'] ?? 0,
          bookId: bookId,
          bookTitle: book.title,
          bookAuthor: book.author,
          isbnNumber: book.isbn,
          userId: j['user_id'] ?? 0,
          userName: j['user_name'] ?? '',
          userType: j['user_type'] ?? 'student',
          admissionOrEmpId: j['admission_no'] ?? '',
          className: j['class_name'] ?? '',
          issueDate: j['issue_date'] ?? '',
          dueDate: j['due_date'] ?? '',
          returnDate: j['return_date'],
          status: j['status'] ?? 'issued',
          fine: (j['fine'] ?? 0).toDouble(),
          finePaid: j['fine_paid'] ?? false,
        );
      }).toList();
    } catch (e) {
      _issues = [];
    }
  }

  void _generateNotifications() {
    _notifications = [];
    int notifId = 1;
    for (final issue in _issues) {
      if (issue.status == 'returned') continue;
      if (issue.isOverdue) {
        _notifications.add(LibraryNotificationModel(
          id: notifId++,
          userId: issue.admissionOrEmpId,
          userName: issue.userName,
          bookTitle: issue.bookTitle,
          message: 'OVERDUE: "${issue.bookTitle}" was due on ${issue.dueDate}. Fine: Rs ${issue.calculatedFine.toStringAsFixed(0)}.',
          type: 'overdue',
          date: DateTime.now().toString().split(' ')[0],
          isRead: false,
        ));
      } else {
        try {
          final parts = issue.dueDate.split('/');
          if (parts.length == 3) {
            final due = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            final daysLeft = due.difference(DateTime.now()).inDays;
            if (daysLeft <= settings.dueSoonReminderDays) {
              _notifications.add(LibraryNotificationModel(
                id: notifId++,
                userId: issue.admissionOrEmpId,
                userName: issue.userName,
                bookTitle: issue.bookTitle,
                message: 'REMINDER: "${issue.bookTitle}" is due in $daysLeft day(s) on ${issue.dueDate}.',
                type: 'due_soon',
                date: DateTime.now().toString().split(' ')[0],
                isRead: false,
              ));
            }
          }
        } catch (_) {}
      }
    }
    notifyListeners();
  }

  Future<bool> addBook({
    required String title, required String author,
    required String isbn, required String category,
    required int copies, String publisher = '', String location = '',
  }) async {
    try {
      await apiService.post('/books', {
        'title': title, 'author': author, 'isbn': isbn,
        'category': category, 'total_copies': copies,
        'available_copies': copies, 'publisher': publisher,
        'location': location,
      });
      await fetchBooks();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> issueBook({
    required int bookId, required int userId,
    required String userType, required String issueDate,
    required String dueDate,
  }) async {
    try {
      await apiService.post('/books/issue', {
        'book_id': bookId,
        'user_id': userId,
        'user_type': userType,
        'issue_date': issueDate,
        'due_date': dueDate,
      });
      await fetchBooks();
      await fetchIssues();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> returnBook(int issueId, {bool collectFine = false}) async {
    try {
      await apiService.put('/books/return/$issueId', {
        'fine_paid': collectFine,
      });
      await fetchBooks();
      await fetchIssues();
      _generateNotifications();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      _books.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void markNotificationRead(int id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = LibraryNotificationModel(
        id: _notifications[idx].id,
        userId: _notifications[idx].userId,
        userName: _notifications[idx].userName,
        bookTitle: _notifications[idx].bookTitle,
        message: _notifications[idx].message,
        type: _notifications[idx].type,
        date: _notifications[idx].date,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void updateSettings(LibrarySettingsModel newSettings) {
    settings = newSettings;
    notifyListeners();
  }

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setFilter(String f) { _filterCategory = f; notifyListeners(); }
}


