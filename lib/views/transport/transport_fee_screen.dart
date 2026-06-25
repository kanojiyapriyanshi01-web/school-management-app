import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../core/theme/app_theme.dart';

class TransportFeeScreen extends StatefulWidget {
  const TransportFeeScreen({super.key});
  @override
  State<TransportFeeScreen> createState() => _TransportFeeScreenState();
}

class _TransportFeeScreenState extends State<TransportFeeScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransportProvider>();
    final fees = p.fees;
    final collected = fees.where((f) => f.status == 'paid').fold(0.0, (s, f) => s + f.amount);
    final pending = fees.where((f) => f.status == 'pending').fold(0.0, (s, f) => s + f.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Summary
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _stat('Total', '${fees.length}', Colors.blue),
            _stat('Collected', 'Rs ${collected.toStringAsFixed(0)}', Colors.green),
            _stat('Pending', 'Rs ${pending.toStringAsFixed(0)}', Colors.orange),
          ])),
        const SizedBox(height: 8),

        Expanded(child: fees.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.receipt, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              const Text('No transport fees', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _addFeeDialog(context),
                icon: const Icon(Icons.add), label: const Text('Add Fee')),
            ]))
          : RefreshIndicator(
              onRefresh: () => p.fetchFees(),
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: fees.length,
                itemBuilder: (ctx, i) => _feeCard(ctx, fees[i], p),
              ))),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFeeDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Fee')),
    );
  }

  Widget _feeCard(BuildContext context, TransportFeeModel f, TransportProvider p) =>
    Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Month: ${f.month}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: f.status == 'paid'
                  ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: Text(f.status.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                  color: f.status == 'paid' ? Colors.green : Colors.orange))),
          ]),
          const Divider(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Rs ${f.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
            if (f.status != 'paid') ElevatedButton.icon(
              onPressed: () async {
                await p.updateFeeStatus(f.id, 'paid');
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fee marked as paid!'),
                    backgroundColor: Colors.green));
              },
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark Paid', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green)),
            if (f.status == 'paid' && f.paidDate.isNotEmpty)
              Text('Paid: ${f.paidDate}',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ]),
      ),
    );

  void _addFeeDialog(BuildContext context) {
    final p = context.read<TransportProvider>();
    final _nameCtrl = TextEditingController();
    final _amountCtrl = TextEditingController();
    final _monthCtrl = TextEditingController(
      text: '${DateTime.now().month}/${DateTime.now().year}');
    int? _studentId;
    int? _vehicleId;
    int? _routeId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Transport Fee'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              hint: const Text('Select Student'),
              items: p.students.map((s) => DropdownMenuItem<int>(
                value: s.studentId,
                child: Text(s.studentName))).toList(),
              onChanged: (v) {
                setS(() {
                  _studentId = v;
                  final student = p.students.firstWhere((s) => s.studentId == v);
                  _nameCtrl.text = student.studentName;
                  _vehicleId = student.vehicleId;
                  _routeId = student.routeId;
                  _amountCtrl.text = student.monthlyFee.toStringAsFixed(0);
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(controller: _amountCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (Rs)')),
            const SizedBox(height: 8),
            TextField(controller: _monthCtrl,
              decoration: const InputDecoration(labelText: 'Month (MM/YYYY)')),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_studentId == null) return;
                Navigator.pop(ctx);
                final ok = await p.createFee({
        'student_id': _studentId,
        'student_name': _nameCtrl.text,
        'vehicle_id': _vehicleId ?? 0,
        'route_id': _routeId ?? 0,
        'amount': double.tryParse(_amountCtrl.text) ?? 0,
        'month': _monthCtrl.text,
        'status': 'pending',
                });
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Fee added!' : 'Failed'),
                    backgroundColor: ok ? Colors.green : Colors.red));
              },
              child: const Text('Add')),
          ])));
  }

  Widget _stat(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
  ]);
}


