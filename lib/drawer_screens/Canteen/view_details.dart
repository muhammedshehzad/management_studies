import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewDetails extends StatelessWidget {
  const ViewDetails({
    super.key,
  });

  Future<QuerySnapshot> fetchTransactionFromFirestore(String userId) async {
    try {
      final transactionSnapshot = await FirebaseFirestore.instance
          .collection('Transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      return transactionSnapshot;
    } catch (e) {
      print('Error fetching transaction data: $e');
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preview'),
        ),
        body: Center(child: Text('User is not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Transactions')
              .where('userId', isEqualTo: user.uid)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No transactions found.'));
            }

            final transactions = snapshot.data!.docs;

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final transactionId = transaction.id;
                final totalAmount = transaction['totalAmount'];
                final timestamp =
                (transaction['timestamp'] as Timestamp).toDate();
                final itemsRef = FirebaseFirestore.instance
                    .collection('Transactions')
                    .doc(transactionId)
                    .collection('Items');

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transaction Date:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(DateFormat('yyyy-MM-dd HH:mm')
                                .format(timestamp)),
                          ],
                        ),
                        const Divider(thickness: 1, height: 20),
                        const Text(
                          'Items Purchased:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<QuerySnapshot>(
                          future: itemsRef.get(),
                          builder: (context, itemsSnapshot) {
                            if (itemsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (itemsSnapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${itemsSnapshot.error}'));
                            }
                            if (!itemsSnapshot.hasData ||
                                itemsSnapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('No items found.'));
                            }

                            final items = itemsSnapshot.data!.docs;
                            return Column(
                              children: items.map((item) {
                                final itemData =
                                item.data() as Map<String, dynamic>;
                                final itemName = itemData['name'];
                                final itemQuantity = itemData['quantity'];
                                final itemPrice = itemData['price'];
                                final discountedPrice =
                                itemData['discountedPrice'];
                                final total = discountedPrice * itemQuantity;

                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('$itemName x $itemQuantity',overflow: TextOverflow.ellipsis,)),
                                      Text(
                                        '₹${total.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const Divider(thickness: 1, height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount Paid:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '₹${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
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
      ),
    );
  }
}