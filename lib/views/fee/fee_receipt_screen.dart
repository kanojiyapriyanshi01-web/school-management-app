import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/fee_provider.dart';

class FeeReceiptScreen extends StatelessWidget {
  final int feeId;
  const FeeReceiptScreen({super.key, required this.feeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/fees')),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt downloaded!'), backgroundColor: Colors.green));
          }),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Receipt card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)]),
            child: Column(children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                child: Column(children: [
                  const Icon(Icons.school, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text('SCHOOL MANAGEMENT SYSTEM',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text('Fee Receipt', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8)),
                    child: Text('Receipt #REC${feeId.toString().padLeft(4,'0')}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
              ),

              // Status badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.green.withOpacity(0.1),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('PAYMENT CONFIRMED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ])),

              // Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  _row('Receipt No', 'REC${feeId.toString().padLeft(4,'0')}'),
                  _row('Date', '19 Jun 2026'),
                  _row('Student Name', 'Rahul Kumar'),
                  _row('Class', 'Class 10-A'),
                  _row('Roll No', 'R001'),
                  _row('Father Name', 'Suresh Kumar'),
                  const Divider(height: 24),
                  _row('Fee Type', 'Tuition Fee'),
                  _row('Period', 'June 2026'),
                  _row('Due Date', '30 Jun 2026'),
                  const Divider(height: 24),
                  _row('Fee Amount', 'Rs. 12,500'),
                  _row('Discount', 'Rs. 0'),
                  _row('Late Fine', 'Rs. 0'),
                  const Divider(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total Paid',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rs. 12,500',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,
                        color: AppTheme.primaryColor)),
                  ]),
                  const SizedBox(height: 16),
                  _row('Payment Mode', 'Cash'),
                  _row('Received By', 'Admin'),
                  const SizedBox(height: 20),

                  // Amount in words
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Amount in Words:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Twelve Thousand Five Hundred Rupees Only',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ])),
                ]),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))),
                child: Column(children: [
                  const Text('This is a computer generated receipt.',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const Text('No signature required.',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Column(children: [
                      Container(width: 80, height: 1, color: Colors.grey),
                      const SizedBox(height: 4),
                      const Text('Parent Signature', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ]),
                    Column(children: [
                      Container(width: 80, height: 1, color: Colors.grey),
                      const SizedBox(height: 4),
                      const Text('Accountant', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ]),
                  ]),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing...'), backgroundColor: Colors.blue)),
              icon: const Icon(Icons.print),
              label: const Text('Print'),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sending via WhatsApp...'), backgroundColor: Colors.green)),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]));
}


