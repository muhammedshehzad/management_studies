import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/Canteen/canteen_page.dart';
import 'package:new_school/drawer_screens/Canteen/cart_page.dart';
import 'package:new_school/drawer_screens/Canteen/view_details.dart';

import '../../sliding_transition.dart';
import 'invoice_page.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
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
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * .27,
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
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
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
                            User? user = FirebaseAuth.instance.currentUser;
                            Navigator.push(
                              context,
                              SlidingPageTransitionRL(
                                page: DownloadInvoice(
                                  userId: user!.uid,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Download Invoice',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
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
                        Navigator.push(
                          context,
                          SlidingPageTransitionRL(page: ViewDetails()),
                        );
                      },
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
