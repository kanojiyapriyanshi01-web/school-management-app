import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

class TransportReportsScreen extends StatelessWidget {
  const TransportReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        _reportCard('Fleet Summary',
        'Total: ${p.totalVehicles} | Active: ${p.activeVehicles} | Maintenance: ${p.maintenanceCount}',
          Icons.directions_bus, Colors.blue),
        _reportCard('Route Summary',
        'Total Routes: ${p.totalRoutes}',
          Icons.route, Colors.green),
        _reportCard('Student Transport',
        'Total Students: ${p.studentsWithTransport}',
          Icons.school, Colors.purple),
        _reportCard('Fee Collection',
        'Collected: Rs ${p.totalFeeCollected.toStringAsFixed(0)} | Pending: Rs ${p.totalFeePending.toStringAsFixed(0)}',
          Icons.payment, Colors.orange),
        const SizedBox(height: 16),
        const Text('Vehicle-wise Report',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ...p.vehicles.map((v) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.directions_bus, color: AppTheme.primaryColor),
            title: Text(v.vehicleNumber),
            subtitle: Text('Driver: ${v.driverName.isEmpty ? "N/A" : v.driverName} ? Route: ${v.assignedRoute.isEmpty ? "N/A" : v.assignedRoute}'),
            trailing: Text(v.status.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                color: v.status == 'active' ? Colors.green : Colors.orange)),
          ))),
      ]),
    );
  }

  Widget _reportCard(String title, String subtitle, IconData icon, Color color) =>
    Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ));
}


