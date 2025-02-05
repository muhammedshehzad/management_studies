// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:new_school/drawer_screens/Canteen/orders_page.dart';
// import 'package:new_school/drawer_screens/Canteen/success_page.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import '../../sliding_transition.dart';
// import 'cart_provider.dart';
// import 'failure_page.dart';
//
// class CheckoutPage extends StatefulWidget {
//   const CheckoutPage({super.key});
//
//   @override
//   State<CheckoutPage> createState() => _CheckoutPageState();
// }
//
// class _CheckoutPageState extends State<CheckoutPage> {
//   final Razorpay _razorpay = Razorpay();
//   String userName = '';
//   bool isLoading = false;
//   bool paymentFailed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     _razorpay.on('modalClosed', _handleModalClosed);
//     // loadDraftOrder();
//   }
//
//   Future<void> _handleModalClosed(response) async {
//     print('Payment modal closed: $response');
//     setState(() {
//       paymentFailed = false;
//     });
//     final totalAmount = context.read<CartProvider>().calculateTotal();
//     await saveTransaction('draft', totalAmount); // Save as failed
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//           content:
//           Text('Payment not completed. Your order is saved as a draft.')),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print('External Wallet: ${response.walletName}');
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     print('Payment Success: $response');
//     final totalAmount = context.read<CartProvider>().calculateTotal();
//     setState(() => isLoading = true);
//
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       // Find transaction using Razorpay's payment ID
//       final transactionSnapshot = await FirebaseFirestore.instance
//           .collection('Transactions')
//           .where('paymentId', isEqualTo: response.paymentId)
//           .limit(1)
//           .get();
//
//       if (transactionSnapshot.docs.isNotEmpty) {
//         final transactionDoc = transactionSnapshot.docs.first;
//         // Delete the draft transaction
//         await transactionDoc.reference.delete();
//         print('Draft deleted after successful payment');
//       }
//
//       // Save successful transaction
//       await saveTransactionToFirestore(
//         totalAmount,
//         status: 'success',
//         paymentId: response.paymentId, // Add this parameter
//       );
//     }
//
//     setState(() => isLoading = false);
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => PaymentSuccessPage()),
//     );
//     context.read<CartProvider>().clearCart();
//   }
//
//   Future<void> saveTransactionToFirestore(double totalAmount,
//       {String status = 'draft', String? paymentId}) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final cartProvider = context.read<CartProvider>();
//       final cartItems = cartProvider.cart;
//
//       try {
//         final transactionRef =
//         FirebaseFirestore.instance.collection('Transactions').doc();
//
//         await transactionRef.set({
//           'userId': user.uid,
//           'paymentId': paymentId, // Store Razorpay's payment ID
//           'userName': userName.isNotEmpty
//               ? userName
//               : (user.displayName ?? 'Test Customer'),
//           'totalAmount': totalAmount,
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': status,
//         });
//
//         for (var entry in cartItems.entries) {
//           final item = entry.value;
//           await transactionRef.collection('Items').add({
//             'name': item['name'],
//             'quantity': item['quantity'],
//             'price': item['price'],
//             'discountedPrice': item['discountedPrice'],
//             'total': item['discountedPrice'] * item['quantity'],
//           });
//         }
//
//         print('Transaction saved successfully with status: $status');
//       } catch (e) {
//         print('Error saving transaction: $e');
//       }
//     }
//   }
//
//   Future<void> initiatePayment() async {
//     final totalAmount = context.read<CartProvider>().calculateTotal();
//
//     if (totalAmount == 0) {
//       print('Amount is zero. Payment not initiated.');
//       return;
//     }
//
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(user.uid)
//           .get();
//
//       if (userDoc.exists && userDoc.data() != null) {
//         var userData = userDoc.data() as Map<String, dynamic>;
//         setState(() {
//           userName = userData['username'] ?? user.displayName ?? 'Unknown User';
//         });
//       }
//     }
//
//     // Save draft before initiating payment
//     // await saveTransaction('draft', totalAmount);
//
//     var options = {
//       'key': 'rzp_test_5e6DvMpFJTW6hs',
//       'amount': (totalAmount * 100).toInt(),
//       'name': userName.isNotEmpty ? userName : 'Test Customer',
//       'description':
//       'Payment for Order #${DateTime.now().millisecondsSinceEpoch}',
//       'prefill': {'contact': '9999999999', 'email': 'example@gmail.com'},
//       'theme': {'color': '#3e948e'},
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print('Error opening Razorpay: $e');
//       await saveTransaction('failed', totalAmount);
//       setState(() {
//         paymentFailed = true;
//       });
//     }
//   }
//
//   Future<void> saveTransaction(String status, double totalAmount) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final cartProvider = context.read<CartProvider>();
//       final cartItems = cartProvider.cart;
//
//       try {
//         final transactionRef =
//         FirebaseFirestore.instance.collection('Transactions').doc();
//
//         await transactionRef.set({
//           'userId': user.uid,
//           'userName': userName.isNotEmpty
//               ? userName
//               : (user.displayName ?? 'Test Customer'),
//           'totalAmount': totalAmount,
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': status, // 'draft', 'success', or 'failed'
//         });
//
//         for (var entry in cartItems.entries) {
//           final item = entry.value;
//           await transactionRef.collection('Items').add({
//             'name': item['name'],
//             'quantity': item['quantity'],
//             'price': item['price'],
//             'discountedPrice': item['discountedPrice'],
//             'total': item['discountedPrice'] * item['quantity'],
//           });
//         }
//
//         print('Transaction saved successfully with status: $status');
//       } catch (e) {
//         print('Error saving transaction: $e');
//       }
//     }
//   }
//
//   Future<void> saveDraftOrder(String status, double totalAmount) async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final cartProvider = context.read<CartProvider>();
//       final cartItems = cartProvider.cart;
//
//       try {
//         final transactionRef =
//         FirebaseFirestore.instance.collection('Transactions').doc();
//
//         await transactionRef.set({
//           'userId': user.uid,
//           'userName': userName.isNotEmpty
//               ? userName
//               : (user.displayName ?? 'Test Customer'),
//           'totalAmount': totalAmount,
//           'timestamp': FieldValue.serverTimestamp(),
//           'status': status, // 'draft', 'success', or 'failed'
//         });
//
//         for (var entry in cartItems.entries) {
//           final item = entry.value;
//           await transactionRef.collection('Items').add({
//             'name': item['name'],
//             'quantity': item['quantity'],
//             'price': item['price'],
//             'discountedPrice': item['discountedPrice'],
//             'total': item['discountedPrice'] * item['quantity'],
//           });
//         }
//
//         print('Transaction saved successfully with status: $status');
//       } catch (e) {
//         print('Error saving transaction: $e');
//       }
//     }
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) async {
//
//     setState(() {
//       paymentFailed = true;
//     });
//     final totalAmount = context.read<CartProvider>().calculateTotal();
//     await saveTransaction('draft', totalAmount); // Save as failed
//     if (paymentFailed) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentFailurePage(),
//         ),
//       );
//     }
//     print('Payment Failed');
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _razorpay.clear();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (paymentFailed) {
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           title: Text('Checkout Page'),
//           centerTitle: true,
//           actions: [
//             IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     SlidingPageTransitionRL(
//                       page: OrdersPage(),
//                     ),
//                   );
//                 },
//                 icon: Icon(Icons.history)),
//             SizedBox(
//               width: 5,
//             )
//           ],
//         ),
//         body: Stack(
//           children: [
//             Stack(
//               children: [
//                 Center(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Column(
//                       children: [
//                         Consumer<CartProvider>(
//                           builder: (context, cartProvider, _) {
//                             if (cartProvider.cart.isEmpty) {
//                               return Expanded(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Center(
//                                       child: Text(
//                                         'Nothing to Checkout !',
//                                         style: TextStyle(
//                                           fontSize: 25,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.grey,
//                                         ),
//                                         overflow: TextOverflow.visible,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     Text(
//                                       'Please add items to Proceed',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.grey,
//                                       ),
//                                       overflow: TextOverflow.visible,
//                                     )
//                                   ],
//                                 ),
//                               );
//                             } else {
//                               return Expanded(
//                                 child: ListView(
//                                   children:
//                                   cartProvider.cart.entries.map((entry) {
//                                     final item = entry.value;
//                                     return Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 '${item['name']} x ${item['quantity']}',
//                                                 style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 15),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                             Text(
//                                               '₹${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 13,
//                                                   color: Colors.grey.shade600),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(height: 20),
//                                         // Divider(),
//                                       ],
//                                     );
//                                   }).toList(),
//                                 ),
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 10,
//                   right: 10,
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                           color: Colors.teal.shade50,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     'Amount Payable:',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   Consumer<CartProvider>(
//                                     builder: (context, cartProvider, _) {
//                                       return Text(
//                                         '₹${cartProvider.calculateTotal().toStringAsFixed(2)}',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.w700,
//                                             fontSize: 18,
//                                             color: Colors.green.shade700),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding:
//                               const EdgeInsets.symmetric(vertical: 4.0),
//                               child: SizedBox(
//                                 width: MediaQuery.of(context).size.width,
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     foregroundColor: Colors.white,
//                                     backgroundColor: Color(0xff3e948e),
//                                     elevation: 3,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                   ),
//                                   onPressed: () async {
//                                     await initiatePayment();
//                                   },
//                                   child: Text(
//                                     'Proceed To Payment',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             if (isLoading)
//               Center(
//                 child: Container(
//                     height: MediaQuery.of(context).size.height,
//                     width: MediaQuery.of(context).size.width,
//                     color: Colors.white,
//                     child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child:
//                         const Center(child: CircularProgressIndicator()))),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
