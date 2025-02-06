import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../sliding_transition.dart';
import 'cart_provider.dart';
import 'checkout_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String? currentTransactionId;

  Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'transactionId': doc.id,
        'userName': data['userName'],
        'totalAmount': data['totalAmount'],
        'timestamp': data['timestamp'],
        'status': data['status'],
        'orderId': data['orderId'],
      };
    }).toList();
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      DocumentReference transactionRef = FirebaseFirestore.instance
          .collection('Transactions')
          .doc(transactionId);

      await deleteSubCollection(transactionRef, 'Items');
      await transactionRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction deleted successfully')),
      );

      print('Transaction and sub-collections deleted successfully.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
      print('Error deleting transaction: $e');
    }
  }

  Future<void> deleteSubCollection(
      DocumentReference parentDoc, String subCollection) async {
    final subCollectionRef = parentDoc.collection(subCollection);
    final subCollectionSnapshot = await subCollectionRef.get();

    for (var doc in subCollectionSnapshot.docs) {
      await doc.reference.delete();
    }

    print('All sub-collection documents deleted successfully.');
  }

  Future<void> retryDraftOrder(String transactionId) async {
    await loadDraftOrder(transactionId);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.pushReplacement(
      context,
      SlidingPageTransitionRL(
        page: CheckoutPage(transactionId: transactionId),
      ),
    );
  }

  Future<void> loadDraftOrder(String transactionId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        setState(() => currentTransactionId = transactionId);
        final transactionRef = FirebaseFirestore.instance
            .collection('Transactions')
            .doc(transactionId);

        final itemsSnapshot = await transactionRef.collection('Items').get();

        if (itemsSnapshot.docs.isNotEmpty) {
          final cartProvider = context.read<CartProvider>();
          cartProvider.clearCart();

          for (var itemDoc in itemsSnapshot.docs) {
            final item = itemDoc.data();
            cartProvider.addToCart(
              item['name'],
              item['quantity'],
              item['price'],
              item['discountedPrice'],
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Draft loaded'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading draft: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Orders'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Transactions')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'transactionId': doc.id,
              'userName': data['userName'],
              'totalAmount': data['totalAmount'],
              'timestamp': data['timestamp'],
              'status': data['status'],
              'orderId': data['orderId'],
            };
          }).toList();

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final String status = transaction['status'] ?? '';
              final bool isSuccess = status == 'success';
              final bool isDraft = status == 'draft';
              final bool isFailed = status == 'failed';

              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        transaction['userName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        'Total Amount: ₹${transaction['totalAmount'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        'Date: ${DateFormat('dd-MM-yyyy, HH:mm').format((transaction['timestamp'] as Timestamp).toDate())}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        'Transaction Id: ${transaction['transactionId']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100,
                            height: 35,
                            decoration: BoxDecoration(
                              color: isSuccess
                                  ? Colors.green.shade600
                                  : isDraft
                                  ? Colors.orange.shade600
                                  : Colors.red.shade600,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Text(
                                isSuccess
                                    ? 'Success'
                                    : isDraft
                                    ? 'Draft'
                                    : 'Failed',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (isFailed || isDraft)
                            SizedBox(
                              height: 35,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff3e948e),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                onPressed: () async {
                                  await retryDraftOrder(
                                      transaction['transactionId']);
                                },
                                child: const Text(
                                  'Retry Payment',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}