import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Role ke hisaab se dashboard route
String getDashboardRoute(BuildContext context) {
  final role = context.read<AuthProvider>().user?.role;
  switch (role) {
    case 'staff':   return '/dashboard/staff';
    case 'student': return '/dashboard/student';
    case 'parent':  return '/dashboard/parent';
    default:        return '/dashboard/admin';
  }
}

