import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';
  bool get isStudent => role == 'student';
  bool get isParent => role == 'parent';
}

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _user;
  String _selectedRole = 'admin';
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get selectedRole => _selectedRole;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ? Shortcut getters ? complaint_screen.dart mein use hote hain
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isStudent => _user?.isStudent ?? false;

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.post('/auth/login', {
        'email': email,
        'password': password,
        'role': _selectedRole,
      }, auth: false);

      await apiService.saveToken(response['token']);

      final userData = response['user'];
      _user = UserModel(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        role: userData['role'],
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuth() async {
    try {
      final response = await apiService.get('/auth/me');
      final userData = response['user'] ?? response;
      _user = UserModel(
        id: userData['id'] ?? 0,
        name: userData['name'] ?? '',
        email: userData['email'] ?? '',
        role: userData['role'] ?? 'student',
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await apiService.clearToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _selectedRole = 'admin';
    notifyListeners();
  }
}

