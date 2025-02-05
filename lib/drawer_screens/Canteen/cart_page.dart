import 'package:flutter/material.dart';
import 'package:new_school/drawer_screens/Canteen/cart_provider.dart';
import 'package:provider/provider.dart';
import '../../sliding_transition.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Cart'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Image.asset(
                        'lib/assets/food-cart.png',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -150,
                top: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4),
                        child: Text(
                          'Order Summary',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.64,
                          ),
                          child: Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                              if (cartProvider.cart.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 200.0),
                                    child: Text(
                                      'Please add items to the cart.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return ListView(
                                  children:
                                      cartProvider.cart.entries.map((entry) {
                                    final item = entry.value;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 6.0),
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 3.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'],
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Price: ₹${item['price'].toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Discount: ${(item['discount'] != null ? (item['discount'] * 100).toInt() : 0)}%',
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Consumer<CartProvider>(
                                                    builder: (context,
                                                            cartProvider, _) =>
                                                        Row(
                                                      children: [
                                                        Text(
                                                          'Discounted Price: ',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Text(
                                                          '₹${cartProvider.calculateDiscountedPrice(item['price'] ?? 0, item['discount'] ?? 0)}',
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .green.shade500,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              right: 10,
                                              top: 60,
                                              child: Text(
                                                '₹${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color:
                                                        Colors.grey.shade600),
                                              ),
                                            ),
                                            Positioned(
                                              top: 26,
                                              right: 7,
                                              child: Container(
                                                height: 36,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        String itemName =
                                                            item['name'];
                                                        context
                                                            .read<
                                                                CartProvider>()
                                                            .removeItem(
                                                                itemName);
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffe0e0e0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 14,
                                                          color:
                                                              Color(0xff3e948e),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12),
                                                      child: Consumer<
                                                          CartProvider>(
                                                        builder: (context,
                                                            cartProvider, _) {
                                                          int quantity = cartProvider
                                                                          .cart[
                                                                      item[
                                                                          'name']]
                                                                  ?[
                                                                  'quantity'] ??
                                                              0;
                                                          return Text(
                                                            '$quantity',
                                                            style: TextStyle(
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black87,
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
                                                            .read<
                                                                CartProvider>()
                                                            .addItem(
                                                              itemName,
                                                              item['price'],
                                                              item['discount'],
                                                            );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffe0e0e0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 14,
                                                          color:
                                                              Color(0xff3e948e),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      // Divider(),

                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 20),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
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
                                color: Colors.red.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
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
                          onPressed: () {
                            if (context.read<CartProvider>().cart.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 5,
                                  content: Text(
                                      'Please add items to the cart before proceeding.'),
                                  backgroundColor: Colors.red.shade600,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                SlidingPageTransitionRL(
                                  page: CheckoutPage(),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Checkout Now',
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
          )
        ],
      ),
    );
  }
}
