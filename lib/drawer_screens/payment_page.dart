// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// class Paymentpage extends StatefulWidget {
//   const Paymentpage({super.key});
//
//   @override
//   State<Paymentpage> createState() => _PaymentpageState();
// }
//
// class _PaymentpageState extends State<Paymentpage> {
//   final Razorpay _razorpay = Razorpay();
//
//
//
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     print('Payment Success: $response');
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     print('Payment Error: $response');
//   }
//
//   // Payment cancelled handler
//   // void _handlePaymentCancelled(PaymentCancelledResponse response) {
//   //   print('Payment Cancelled: $response');
//   //   // Handle payment cancellation (e.g., show a cancellation message)
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           Center(
//             child: Image.asset('lib/assets/payment.jpg'),
//           ),
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Text(
//                   'Make Payment',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             bottom: 10,
//             left: 10,
//             right: 10,
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * .9,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   foregroundColor: Colors.white,
//                   backgroundColor: Color(0xff3e948e),
//                   elevation: 3,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 onPressed: () async {
//                   await initiatePayment();
//                 },
//                 child: Text(
//                   'Payment Gateway',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
