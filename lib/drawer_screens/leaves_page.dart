import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sliding_transition.dart';
import 'checkout_page.dart';
import 'package:badges/badges.dart' as badges;
import 'cart_provider.dart';

class LeavesPage extends StatelessWidget {
   LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canteen Menu'),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) => badges.Badge(
              badgeAnimation: badges.BadgeAnimation.fade(),
              badgeContent: Text(
                '${cartProvider.getTotalCartItems()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              position: badges.BadgePosition.topEnd(top: -6, end: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidingPageTransitionRL(page: CheckOutPage()),
                  );
                },
                icon: Image.asset(
                  'lib/assets/shopping-cart.png',
                  height: 25,
                  width: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
