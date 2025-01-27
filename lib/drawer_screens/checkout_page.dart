import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/cart_provider.dart';
import 'package:new_school/drawer_screens/payment_page.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckOutPage extends StatefulWidget {
  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  final Razorpay _razorpay = Razorpay();

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: $response');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: $response');
  }

  Future<void> initiatePayment() async {
    var options = {
      'key': 'rzp_test_5e6DvMpFJTW6hs',
      'amount': 100,
      'name': 'Test Customer',
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
    // Clean up Razorpay listeners
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
                              children: cartProvider.cart.entries.map((entry) {
                                final item = entry.value;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Use Expanded only within Flex widgets like Row or Column
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
                                                String itemName = item['name'];
                                                context
                                                    .read<CartProvider>()
                                                    .removeItem(itemName);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Color(0xffe0e0e0),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 14,
                                                  color: Color(0xff3e948e),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Consumer<CartProvider>(
                                                builder:
                                                    (context, cartProvider, _) {
                                                  int quantity =
                                                      cartProvider.cart[
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
                                                String itemName = item['name'];
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
                                                      BorderRadius.circular(6),
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
    );
  }
}
