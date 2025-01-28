import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'invoice_page.dart';

class CheckOutPage extends StatefulWidget {
  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final Razorpay _razorpay = Razorpay();
  String userName = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: $response');

    // Show the loading indicator
    setState(() {
      isLoading = true;
    });

    await saveTransactionToFirestore();

    // Hide the loading indicator
    setState(() {
      isLoading = false;
    });

    User? user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadInvoice(userId: user!.uid),
      ),
    );

    context.read<CartProvider>().clearCart();
  }

  Future<void> saveTransactionToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartProvider = context.read<CartProvider>();
      final cartItems = cartProvider.cart;
      final totalAmount = cartProvider.calculateTotal();

      try {
        final transactionRef =
            FirebaseFirestore.instance.collection('Transactions').doc();

        await transactionRef.set({
          'userId': user.uid,
          'userName': userName.isNotEmpty ? userName : 'Test Customer',
          'totalAmount': totalAmount,
          'timestamp': FieldValue.serverTimestamp(),
        });

        for (var entry in cartItems.entries) {
          final item = entry.value;
          await transactionRef.collection('Items').add({
            'name': item['name'],
            'quantity': item['quantity'],
            'price': item['price'],
            'discountedPrice': item['discountedPrice'],
            'total': item['discountedPrice'] * item['quantity'],
          });
        }

        print('Transaction saved successfully');
      } catch (e) {
        print('Error saving transaction: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: $response');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentFailurePage(),
      ),
    );
  }

  Future<void> initiatePayment() async {
    final totalAmount = context.read<CartProvider>().calculateTotal();

    if (totalAmount == 0) {
      print('Amount is zero. Payment not initiated.');
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc['username'] ?? 'Test Customer';
      });
    }

    var options = {
      'key': 'rzp_test_5e6DvMpFJTW6hs',
      'amount': (totalAmount * 100).toInt(),
      'name': userName.isNotEmpty ? userName : 'Test Customer',
      'description':
          'Payment for Order #${DateTime.now().millisecondsSinceEpoch}',
      'prefill': {'contact': '9999999999', 'email': 'example@gmail.com'},
      'theme': {'color': '#3e948e'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Checkout Page'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Stack(
            children: [
              Center(
                  child: Image.asset(
                'lib/assets/3979020.jpg',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              )),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Consumer<CartProvider>(
                              builder: (context, cartProvider, _) {
                                return Column(
                                  children:
                                      cartProvider.cart.entries.map((entry) {
                                    final item = entry.value;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['name']} x${item['quantity']}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    String itemName =
                                                        item['name'];
                                                    context
                                                        .read<CartProvider>()
                                                        .removeItem(itemName);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffe0e0e0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 14,
                                                      color: Color(0xff3e948e),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  child: Consumer<CartProvider>(
                                                    builder: (context,
                                                        cartProvider, _) {
                                                      int quantity = cartProvider
                                                                      .cart[
                                                                  item['name']]
                                                              ?['quantity'] ??
                                                          0;
                                                      return Text(
                                                        '$quantity',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    String itemName =
                                                        item['name'];
                                                    context
                                                        .read<CartProvider>()
                                                        .addItem(
                                                            itemName,
                                                            item['price'],
                                                            item['discount']);
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffe0e0e0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: Color(0xff3e948e),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            '₹${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.grey.shade600),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Divider(),
                                      ],
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Consumer<CartProvider>(
                                  builder: (context, cartProvider, _) {
                                    return Text(
                                      'Total: ₹${cartProvider.calculateTotal().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<CartProvider>().clearCart();
                                  },
                                  child: Text(
                                    'Clear All',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .9,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xff3e948e),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () async {
                                  await initiatePayment();
                                },
                                child: Text(
                                  'Proceed To Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Center(child: CircularProgressIndicator()))),
            ),
        ],
      ),
    );
  }
}

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: Text(
          'Payment Status',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade100,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Payment Successful!',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your transaction has been completed successfully.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .27,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show OK/Cancel dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Do you want to Close?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.pop(context);
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      Spacer(),
                      // SizedBox(width: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .5,
                        child: ElevatedButton(
                          onPressed: () {
                            User? user = FirebaseAuth.instance.currentUser;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DownloadInvoice(
                                  userId: user!.uid,
                                ),
                              ),
                            );
                          },
                          child: Text('Download Invoice'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentFailurePage extends StatelessWidget {
  const PaymentFailurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red.shade100,
        title: Text(
          'Payment Failed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 4,
                  blurRadius: 10,
                  offset: Offset(0, 4), // Shadow position
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Payment Failed!',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Oops! Something went wrong. Please try again.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .27,
                        child: ElevatedButton(
                          onPressed: () {
                            // Show OK/Cancel dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Are you sure?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        Navigator.pop(context);
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                      Spacer(),
                      // SizedBox(width: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .5,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Do you want to try Again?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CheckOutPage()));
                                      },
                                      child: Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Try again?'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
