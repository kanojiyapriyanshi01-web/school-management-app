import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class LibraryNotificationsScreen extends StatelessWidget {
  const LibraryNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final role = context.watch<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';

    // Admin sees all notifications, student/staff sees only their own
    final notifications = isAdmin
      ? p.notifications
      : p.notifications.where((n) => n.userId == 'ADM001' || n.userId == 'EMP002').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: notifications.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No notifications', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: notifications.length,
            itemBuilder: (context, i) {
              final n = notifications[i];
              final isOverdue = n.type == 'overdue';
              final color = isOverdue ? Colors.red : Colors.orange;
              final icon = isOverdue ? Icons.warning_amber : Icons.notifications_active;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: n.isRead ? null : (isOverdue ? Colors.red.shade50 : Colors.orange.shade50),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle),
                        child: Icon(icon, color: color, size: 22)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (isAdmin) Text(n.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(n.bookTitle,
                          style: TextStyle(fontWeight: isAdmin ? FontWeight.normal : FontWeight.bold,
                            fontSize: isAdmin ? 12 : 13, color: isAdmin ? Colors.grey : Colors.black87)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(isOverdue ? 'OVERDUE' : 'DUE SOON',
                            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 2),
                        if (!n.isRead) Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withOpacity(0.2))),
                      child: Text(n.message,
                        style: TextStyle(fontSize: 12, color: isOverdue ? Colors.red.shade800 : Colors.orange.shade900)),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(n.date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      if (!n.isRead) TextButton(
                        onPressed: () => p.markNotificationRead(n.id),
                        child: const Text('Mark as Read', style: TextStyle(fontSize: 12)),
                      ),
                    ]),
                  ]),
                ),
              );
            },
          ),
    );
  }
}

