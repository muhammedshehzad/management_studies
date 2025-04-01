import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/Canteen/success_page.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'cart_provider.dart';
import 'failure_page.dart';

class CheckoutPage extends StatefulWidget {
  final String? transactionId;

  const CheckoutPage({Key? key, this.transactionId}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final Razorpay _razorpay = Razorpay();
  String userName = '';
  bool isLoading = false;
  bool paymentFailed = false;
  String? currentTransactionId;
  bool isOnline = false;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    checkInternet();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay.on('modalClosed', _handleModalClosed);
    currentTransactionId = widget.transactionId;
    // loadDraftOrder();
  }

  void _handleModalClosed(response) {
    print('Payment modal closed: $response');
    setState(() {
      paymentFailed = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Payment not completed. Your order is saved as a draft.')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  Future<void> fetchTransactionByPaymentId(String paymentId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Transactions')
          .where('paymentId', isEqualTo: paymentId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var transactionData = snapshot.docs.first.data();
        print('Transaction data: $transactionData');
      } else {
        print('No transaction found with this payment ID');
      }
    } catch (e) {
      print('Error fetching transaction: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment Success: ${response.paymentId}');
    final totalAmount = context.read<CartProvider>().calculateTotal();
    setState(() => isLoading = true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await saveTransactionToFirestore(
        totalAmount,
        status: 'success',
        paymentId: response.paymentId,
      );

      final String transactionIdToPass = currentTransactionId ?? '';
      setState(() => currentTransactionId = null);

      setState(() => isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessPage(
            transactionId: transactionIdToPass,
          ),
        ),
      );
      context.read<CartProvider>().clearCart();
    }
  }

  String generateUniqueOrderId() {
    var uuid = Uuid();
    return uuid.v4();
  }

  Future<void> saveTransactionToFirestore(double totalAmount,
      {String status = 'draft', String? paymentId, String? orderId}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartProvider = context.read<CartProvider>();
      final cartItems = cartProvider.cart;

      try {
        DocumentReference transactionRef;

        if (currentTransactionId != null) {
          transactionRef = FirebaseFirestore.instance
              .collection('Transactions')
              .doc(currentTransactionId);
        } else {
          transactionRef =
              FirebaseFirestore.instance.collection('Transactions').doc();
          currentTransactionId = transactionRef.id;
        }

        final generatedOrderId =
            (currentTransactionId == null && orderId == null)
                ? generateUniqueOrderId()
                : orderId;

        await transactionRef.set({
          'userId': user.uid,
          'paymentId': paymentId,
          'userName': userName.isNotEmpty
              ? userName
              : (user.displayName ?? 'Test Customer'),
          'totalAmount': totalAmount,
          'timestamp': FieldValue.serverTimestamp(),
          'status': status,
          'orderId':
              generatedOrderId ?? await getExistingOrderId(transactionRef),
        }, SetOptions(merge: true));

        if (status == 'draft') {
          await updateCartItems(transactionRef, cartItems, orderId);
        }
      } catch (e) {
        print('Error saving transaction: $e');
      }
    }
  }

  Future<String> getExistingOrderId(DocumentReference ref) async {
    final doc = await ref.get();
    return doc.exists ? doc.get('orderId') : generateUniqueOrderId();
  }

  Future<void> deleteSubCollection(
      DocumentReference parentDoc, String subCollection) async {
    final subCollectionRef = parentDoc.collection(subCollection);
    final subCollectionSnapshot = await subCollectionRef.get();

    for (var doc in subCollectionSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateCartItems(DocumentReference transactionRef,
      Map<String, dynamic> cartItems, String? orderId) async {

    if (currentTransactionId != null) {
      await deleteSubCollection(transactionRef, 'Items');
    }

    for (var entry in cartItems.entries) {
      final item = entry.value;
      await transactionRef.collection('Items').add({
        'name': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
        'discountedPrice': item['discountedPrice'],
        'total': item['discountedPrice'] * item['quantity'],
        'orderId': orderId,
      });
    }
  }

  Future<void> initiatePayment() async {
    final totalAmount = context.read<CartProvider>().calculateTotal();

    if (totalAmount == 0) return;
    await saveTransactionToFirestore(totalAmount, status: 'draft');

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['username'] ?? user.displayName ?? 'Unknown User';
        });
      }
    }

    final orderResponse = await createRazorpayOrder(totalAmount);
    var options = {
      'key': 'rzp_test_5e6DvMpFJTW6hs',
      'amount': (totalAmount * 100).toInt(),
      'name': userName.isNotEmpty ? userName : 'Test Customer',
      'order_id': orderResponse['id'],
      'description':
          'Payment for Order #${DateTime.now().millisecondsSinceEpoch}',
      'prefill': {'contact': '9999999999', 'email': 'example@gmail.com'},
      'theme': {'color': '#3e948e'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay: $e');
      await saveTransaction('failed', totalAmount);
      setState(() {
        paymentFailed = true;
      });
    }
  }

  Future<Map<String, dynamic>> createRazorpayOrder(double amount) async {
    final authString = base64Encode(
        utf8.encode('rzp_test_5e6DvMpFJTW6hs:7htxVKXoKDXGywu8fnaKRIY7'));

    final response = await http.post(
      Uri.parse('https://api.razorpay.com/v1/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $authString'
      },
      body: jsonEncode({
        'amount': (amount * 100).toInt(),
        'currency': 'INR',
        'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        'payment_capture': 1
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<void> saveTransaction(String status, double totalAmount,
      {String? paymentId}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartProvider = context.read<CartProvider>();
      final cartItems = cartProvider.cart;

      try {
        final transactionRef =
            FirebaseFirestore.instance.collection('Transactions').doc();

        await transactionRef.set({
          'userId': user.uid,
          'userName': userName.isNotEmpty
              ? userName
              : (user.displayName ?? 'Test Customer'),
          'totalAmount': totalAmount,
          'timestamp': FieldValue.serverTimestamp(),
          'status': status,

          'paymentId': paymentId ?? '',

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

        print('Transaction saved successfully with status: $status');
      } catch (e) {
        print('Error saving transaction: $e');
      }
    }
  }

  Future<void> saveDraftOrder(String status, double totalAmount) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartProvider = context.read<CartProvider>();
      final cartItems = cartProvider.cart;

      try {
        final transactionRef =
            FirebaseFirestore.instance.collection('Transactions').doc();

        await transactionRef.set({
          'userId': user.uid,
          'userName': userName.isNotEmpty
              ? userName
              : (user.displayName ?? 'Test Customer'),
          'totalAmount': totalAmount,
          'timestamp': FieldValue.serverTimestamp(),
          'status': status,
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

        print('Transaction saved successfully with status: $status');
      } catch (e) {
        print('Error saving transaction: $e');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    final totalAmount = context.read<CartProvider>().calculateTotal();
    setState(() => isLoading = true);
    await saveTransactionToFirestore(totalAmount, status: 'failed');
    setState(() => isLoading = false);
    setState(() => paymentFailed = true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaymentFailurePage()),
    );
  }

  Widget _buildLoadingOverlay() {
    return isLoading
        ? Positioned.fill(
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Future<void> checkInternet() async {
    bool connected = await hasInternet();
    setState(() {
      isOnline = connected;
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      bool connected =
          results.any((result) => result != ConnectivityResult.none) &&
              await hasInternet();
      setState(() {
        isOnline = connected;
      });
    });
  }

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
    _connectivitySubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Checkout Page'),
            centerTitle: true,
            actions: [
              SizedBox(width: 5),
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: Column(
                    children: [
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, _) {
                          if (cartProvider.cart.isEmpty) {
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Nothing to Checkout !',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Please add items to Proceed',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Expanded(
                              child: ListView(
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
                                              '${item['name']} x ${item['quantity']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '₹${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 10,
                right: 10,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Amount Payable:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Consumer<CartProvider>(
                                    builder: (context, cartProvider, _) {
                                      return Text(
                                        '₹${cartProvider.calculateTotal().toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color: Colors.green.shade700),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
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
                                    setState(() {
                                      isLoading = true; // Show loading screen
                                    });
                                    isOnline
                                        ? await initiatePayment()
                                        : ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'No internet connection detected. Please check your connection and try again later.'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              margin: const EdgeInsets.all(10),
                                              duration:
                                                  const Duration(seconds: 2),
                                              backgroundColor:
                                                  Colors.red.shade500,
                                            ),
                                          );

                                    setState(() {
                                      isLoading = false;
                                    });
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
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildLoadingOverlay()
      ],
    );
  }
}
