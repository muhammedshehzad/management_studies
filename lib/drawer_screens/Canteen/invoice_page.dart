import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../sliding_transition.dart';
import 'cart_page.dart';

class DownloadInvoice extends StatelessWidget {
  final String userId;

  DownloadInvoice({super.key, required this.userId});

  Future<Map<String, dynamic>> fetchTransaction() async {
    final transactionsQuery = await FirebaseFirestore.instance
        .collection('Transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (transactionsQuery.docs.isNotEmpty) {
      final transactionDoc = transactionsQuery.docs.first;
      final transactionData = transactionDoc.data();
      final itemsQuery =
          await transactionDoc.reference.collection('Items').get();
      final items = itemsQuery.docs.map((doc) => doc.data()).toList();
      return {
        'Transaction': transactionData,
        'Items': items,
      };
    }
    return {};
  }

  Future<void> generateInvoicePdf(Map<String, dynamic> transaction,
      List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();
    final timestamp = (transaction['timestamp'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd-MM-yyyy').format(timestamp);
    final formattedTime = DateFormat('HH:mm:ss').format(timestamp);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'Invoice',
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 12),

              // Divider
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Customer info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Customer Name:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    '${transaction['userName']}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Transaction Time:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    '$formattedDate, $formattedTime',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Items section
              pw.Text(
                'Items Purchased:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${item['name']} x${item['quantity']}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        '${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.normal,
                          color: PdfColors.grey.shade(700),
                        ),
                      ),
                    ],
                  );
                },
              ),
              pw.SizedBox(height: 16),

              // Divider
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Total section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount Paid:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    '${transaction['totalAmount'].toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Spacer(),
              pw.Text(
                'School Management App.',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Download'),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           SlidingPageTransitionRL(
        //             page: RecentTransactions(),
        //           ),
        //         );
        //       },
        //       icon: Icon(Icons.history)),
        // ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransaction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final transaction = snapshot.data!['Transaction'];
            final itemsBought =
                snapshot.data!['Items'] as List<Map<String, dynamic>>;
            if (transaction == null || itemsBought.isEmpty) {
              return const Center(child: Text('No transaction details found.'));
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Divider(thickness: 1, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Customer Name:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(transaction['userName']),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Transaction Time:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('HH:mm:ss  dd-MM-yyyy').format(
                                  (transaction['timestamp'] as Timestamp)
                                      .toDate()),
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const Divider(thickness: 1, height: 20),
                        const Text(
                          'Items Purchased:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: itemsBought.length,
                            itemBuilder: (context, index) {
                              final item = itemsBought[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item['name']} x${item['quantity']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '₹${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Divider(thickness: 1, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount Paid:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '₹${transaction['totalAmount'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xff3e948e),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Text(
                              'Download',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            label: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await generateInvoicePdf(
                                  transaction, itemsBought);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('No data found.'));
        },
      ),
    );
  }
}
