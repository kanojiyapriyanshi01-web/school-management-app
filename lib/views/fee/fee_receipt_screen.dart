import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/theme/app_theme.dart';

class FeeReceiptScreen extends StatelessWidget {
  final int feeId;
  const FeeReceiptScreen({super.key, required this.feeId});

  // --- PDF Generator ---
  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final receiptNo = 'REC${feeId.toString().padLeft(4, '0')}';

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header
            pw.Container(
              color: PdfColor.fromHex('#1565C0'),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                children: [
                  pw.Text('SCHOOL MANAGEMENT SYSTEM',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16)),
                  pw.SizedBox(height: 4),
                  pw.Text('Fee Receipt',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 12)),
                  pw.SizedBox(height: 8),
                  pw.Text('Receipt #$receiptNo',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
            ),

            // Payment confirmed
            pw.Container(
              color: PdfColor.fromHex('#E8F5E9'),
              padding: const pw.EdgeInsets.symmetric(vertical: 10),
              child: pw.Center(
                child: pw.Text('✓ PAYMENT CONFIRMED',
                    style: pw.TextStyle(
                        color: PdfColor.fromHex('#2E7D32'),
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 13)),
              ),
            ),

            pw.SizedBox(height: 16),

            // Details
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: pw.Column(
                children: [
                  _pdfRow('Receipt No', receiptNo),
                  _pdfRow('Date', '19 Jun 2026'),
                  _pdfRow('Student Name', 'Rahul Kumar'),
                  _pdfRow('Class', 'Class 10-A'),
                  _pdfRow('Roll No', 'R001'),
                  _pdfRow('Father Name', 'Suresh Kumar'),
                  pw.Divider(),
                  _pdfRow('Fee Type', 'Tuition Fee'),
                  _pdfRow('Period', 'June 2026'),
                  _pdfRow('Due Date', '30 Jun 2026'),
                  pw.Divider(),
                  _pdfRow('Fee Amount', 'Rs. 12,500'),
                  _pdfRow('Discount', 'Rs. 0'),
                  _pdfRow('Late Fine', 'Rs. 0'),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Paid',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Text('Rs. 12,500',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 15,
                              color: PdfColor.fromHex('#1565C0'))),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  _pdfRow('Payment Mode', 'Cash'),
                  _pdfRow('Received By', 'Admin'),
                  pw.SizedBox(height: 16),

                  // Amount in words box
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Amount in Words:',
                            style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('Twelve Thousand Five Hundred Rupees Only',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Signatures
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Column(children: [
                        pw.Container(width: 100, height: 1, color: PdfColors.grey),
                        pw.SizedBox(height: 4),
                        pw.Text('Parent Signature',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ]),
                      pw.Column(children: [
                        pw.Container(width: 100, height: 1, color: PdfColors.grey),
                        pw.SizedBox(height: 4),
                        pw.Text('Accountant',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                      ]),
                    ],
                  ),

                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Text(
                      'This is a computer generated receipt. No signature required.',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ));

    return Uint8List.fromList(await pdf.save());
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(color: PdfColors.grey, fontSize: 11)),
            pw.Text(value,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ],
        ),
      );

  // --- Download PDF ---
  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await _generatePdf();
      final receiptNo = 'REC' + feeId.toString().padLeft(4, '0');
      final fileName = 'FeeReceipt_' + receiptNo + '.pdf';

      // Use temp dir + share sheet — works on all Android versions
      final dir = await getTemporaryDirectory();
      final file = File(dir.path + '/' + fileName);
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Fee Receipt - ' + receiptNo,
        text: 'Tap Save / Download to keep this PDF.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download failed: ' + e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

    // --- Share PDF ---
  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await _generatePdf();
      final dir = await getTemporaryDirectory();
      final receiptNo = 'REC${feeId.toString().padLeft(4, '0')}';
      final file = File('${dir.path}/FeeReceipt_$receiptNo.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Fee Receipt - $receiptNo',
        text: 'Please find the fee receipt attached.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Share failed: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // --- Print PDF ---
  Future<void> _printPdf(BuildContext context) async {
    try {
      final bytes = await _generatePdf();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Print failed: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptNo = 'REC${feeId.toString().padLeft(4, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Receipt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/fees'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () => _sharePdf(context),
          ),
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
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)
              ],
            ),
            child: Column(children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(children: [
                  const Icon(Icons.school, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  const Text('SCHOOL MANAGEMENT SYSTEM',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const Text('Fee Receipt',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Receipt #$receiptNo',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ]),
              ),

              // Status badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.green.withOpacity(0.1),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('PAYMENT CONFIRMED',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  _row('Receipt No', receiptNo),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rs. 12,500',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.primaryColor)),
                    ],
                  ),
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
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount in Words:',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Twelve Thousand Five Hundred Rupees Only',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12)),
                      ],
                    ),
                  ),
                ]),
              ),

              // Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(children: [
                  const Text('This is a computer generated receipt.',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const Text('No signature required.',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(children: [
                        Container(width: 80, height: 1, color: Colors.grey),
                        const SizedBox(height: 4),
                        const Text('Parent Signature',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                      Column(children: [
                        Container(width: 80, height: 1, color: Colors.grey),
                        const SizedBox(height: 4),
                        const Text('Accountant',
                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _printPdf(context),
                icon: const Icon(Icons.print),
                label: const Text('Print'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sharePdf(context),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
          ]),

          const SizedBox(height: 8),

          // Download button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _downloadPdf(context),
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}