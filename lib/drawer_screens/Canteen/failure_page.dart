import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/Canteen/canteen_page.dart';
import 'package:new_school/drawer_screens/Canteen/checkout_page.dart';

import '../../sliding_transition.dart';
import 'cart_page.dart';


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
                  SizedBox(height: 8),
                  Text(
                    'Payment Failed!',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Oops! Something went wrong. Please try again.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .27,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * .5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black54,
                                backgroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width * .5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black54,
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  SlidingPageTransitionLR(
                                      page: CheckoutPage()));
                            },
                            child: const Text(
                              'Try again',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
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
