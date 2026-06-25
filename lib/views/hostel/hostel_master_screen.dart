import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class HostelMasterScreen extends StatelessWidget {
  const HostelMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/hostel/admission'),
        icon: const Icon(Icons.add),
        label: const Text('Add Hostel'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: p.hostels.isEmpty
        ? const Center(child: Text('No hostels found', style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: p.hostels.length,
            itemBuilder: (context, i) {
              final h = p.hostels[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        CircleAvatar(
                          backgroundColor: h.type == 'boys'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.pink.withOpacity(0.1),
                          child: Icon(h.type == 'boys' ? Icons.man : Icons.woman,
                            color: h.type == 'boys' ? Colors.blue : Colors.pink)),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Code: ${h.code}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                      ]),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: h.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(h.status.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                              color: h.status == 'active' ? Colors.green : Colors.red))),
                        PopupMenuButton(
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                          onSelected: (val) {
                            if (val == 'delete') p.deleteHostel(h.id);
                            if (val == 'edit') _showAddHostelDialog(context, hostel: h);
                          },
                        ),
                      ]),
                    ]),
                    const Divider(),
                    Row(children: [
                      Expanded(child: _info('Warden', h.wardenName)),
                      Expanded(child: _info('Phone', h.phone)),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(child: _info('Floors', '${h.floors}')),
                      Expanded(child: _info('Type', h.type.toUpperCase())),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(child: _info('Total Rooms', '${h.totalRooms}')),
                      Expanded(child: _info('Occupied', '${h.occupiedRooms}')),
                      Expanded(child: _info('Vacant', '${h.vacantRooms}')),
                    ]),
                  ]),
                ),
              );
            },
          ),
    );
  }

  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
  ]);

  void _showAddHostelDialog(BuildContext context, {dynamic hostel}) {
    final _nameCtrl = TextEditingController(text: hostel?.name ?? '');
    final _codeCtrl = TextEditingController(text: hostel?.code ?? '');
    final _wardenCtrl = TextEditingController(text: hostel?.wardenName ?? '');
    final _phoneCtrl = TextEditingController(text: hostel?.phone ?? '');
    final _emailCtrl = TextEditingController(text: hostel?.email ?? '');
    String type = hostel?.type ?? 'boys';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(hostel == null ? 'Add Hostel' : 'Edit Hostel'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Hostel Name *')),
            const SizedBox(height: 10),
            TextField(controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Hostel Code *')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['boys','girls','coed'].map((t) =>
                DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
              onChanged: (v) => setS(() => type = v!),
            ),
            const SizedBox(height: 10),
            TextField(controller: _wardenCtrl,
              decoration: const InputDecoration(labelText: 'Warden Name')),
            const SizedBox(height: 10),
            TextField(controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            TextField(controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(hostel == null ? 'Hostel added!' : 'Hostel updated!'),
                    backgroundColor: Colors.green));
              },
              child: Text(hostel == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}



