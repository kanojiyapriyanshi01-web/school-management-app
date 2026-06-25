import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

class DriverManagementScreen extends StatelessWidget {
  const DriverManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();
    final drivers = p.vehicles.where((v) => v.driverName.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: drivers.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.person, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('No drivers assigned', style: TextStyle(color: Colors.grey)),
            const Text('Add vehicles with driver details first',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: drivers.length,
            itemBuilder: (ctx, i) {
              final v = drivers[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        radius: 24,
                        child: Text(
                          v.driverName.isNotEmpty ? v.driverName[0] : 'D',
                          style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(v.driverName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Vehicle: ${v.vehicleNumber}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Text('ACTIVE',
                          style: TextStyle(fontSize: 10,
                            fontWeight: FontWeight.bold, color: Colors.green))),
                    ]),
                    const Divider(height: 14),
                    Row(children: [
                      Expanded(child: _info('Phone', v.driverPhone.isEmpty ? 'N/A' : v.driverPhone)),
                      Expanded(child: _info('License', v.driverLicense.isEmpty ? 'N/A' : v.driverLicense)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(child: _info('Route', v.assignedRoute.isEmpty ? 'N/A' : v.assignedRoute)),
                      Expanded(child: _info('Vehicle Type', v.vehicleType)),
                    ]),
                    if (v.conductorName.isNotEmpty) ...[
                      const Divider(height: 12),
                      Row(children: [
                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Conductor: ${v.conductorName}',
                          style: const TextStyle(fontSize: 12)),
                        if (v.conductorPhone.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text('(${v.conductorPhone})',
                            style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ]),
                    ],
                  ]),
                ),
              );
            }),
    );
  }

  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      overflow: TextOverflow.ellipsis),
  ]);
}


