import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checkout_page.dart';
import 'package:badges/badges.dart' as badges;
import 'cart_provider.dart';

class CanteenMenuPage extends StatefulWidget {
  const CanteenMenuPage({super.key});

  @override
  _CanteenMenuPageState createState() => _CanteenMenuPageState();
}

class _CanteenMenuPageState extends State<CanteenMenuPage> {
  List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Masala Dosa',
      'price': 50.0,
      'discount': 0.1,
      'image': 'lib/assets/masala_dosa.jpg',
    },
    {
      'name': 'Puttu and Kadala Curry',
      'price': 60.0,
      'discount': 0.15,
      'image': 'lib/assets/puttu_kadala.JPG',
    },
    {
      'name': 'Fresh Lime Soda',
      'price': 30.0,
      'discount': 0.1,
      'image': 'lib/assets/freshLime.jpeg',
    },
    {
      'name': 'Appam and Stew',
      'price': 70.0,
      'discount': 0.2,
      'image': 'lib/assets/appam_stew.jpg',
    },
    {
      'name': 'Idli and Sambar',
      'price': 35.0,
      'discount': 0.05,
      'image': 'lib/assets/idli_sambar.jpg',
    },
    {
      'name': 'Tender Coconut Water',
      'price': 50.0,
      'discount': 0.05,
      'image': 'lib/assets/tender-coconut-water-powder.jpg',
    },
    {
      'name': 'Chicken Biryani',
      'price': 90.0,
      'discount': 0.1,
      'image': 'lib/assets/chicken-biryani.jpg',
    },
    {
      'name': 'Kerala Parotta and Beef Fry',
      'price': 100.0,
      'discount': 0.2,
      'image': 'lib/assets/porotta_beef.jpg',
    },
    {
      'name': 'Fish Curry Meal',
      'price': 90.0,
      'discount': 0.15,
      'image': 'lib/assets/fish_curry_meal.jpg',
    },
    {
      'name': 'Banana Fry (Pazham Pori)',
      'price': 12.0,
      'discount': 0.05,
      'image': 'lib/assets/banana_fry.jpg',
    },
    {
      'name': 'Chai (Tea)',
      'price': 12.0,
      'discount': 0.05,
      'image': 'lib/assets/chai.jpg',
    },
    {
      'name': 'Sadhya (Vegetarian Meal)',
      'price': 70.0,
      'discount': 0.25,
      'image': 'lib/assets/sadhya.jpg',
    },
    {
      'name': 'Nadan Kozhi Curry (Country Chicken Curry)',
      'price': 80.0,
      'discount': 0.1,
      'image': 'lib/assets/kozhi_curry.jpeg',
    },
    {
      'name': 'Cold Coffee',
      'price': 40.0,
      'discount': 0.1,
      'image': 'lib/assets/istockphoto-1366850534-612x612.jpg',
    },
    {
      'name': 'Thalassery Dum Biryani',
      'price': 110.0,
      'discount': 0.2,
      'image': 'lib/assets/thalassery_biriyani.jpeg',
    },
  ];

  Map<String, Map<String, dynamic>> cart = {};

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
                    MaterialPageRoute(
                      builder: (context) => CheckOutPage(),
                    ),
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
      body: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600
                        ? 2
                        : (MediaQuery.of(context).size.width < 800 ? 3 : 4),
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    // final discountedPrice = calculateDiscountedPrice(
                    //     item['price'], item['discount']);
                    return Container(
                      child: Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10.0)),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.asset(
                                    item['image'] ??
                                        'lib/assets/placeholder_image.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Price: ₹${item['price'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Discount: ${(item['discount'] * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Consumer<CartProvider>(
                                      builder: (context, cartProvider, _) =>
                                          Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '₹${cartProvider.calculateDiscountedPrice(item['price'], item['discount'])}',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade500,
                                              ),
                                            ),
                                            // Quantity control buttons
                                            Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Color(0xffd1d1d1),
                                                    width: 1),
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
                                                            itemName,
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
                                                              ?['quantity'] ??
                                                          0;
                                                      return Text(
                                                        '$quantity',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.black87,
                                                        ),
                                                      );
                                                    }),
                                                  ),
                                                  Consumer<CartProvider>(
                                                    builder: (context,
                                                            cartProvider,
                                                            _) =>
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
                                                              item[
                                                                  'discount'],
                                                            );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color(
                                                              0xffe0e0e0),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6),
                                                        ),
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 14,
                                                          color: Color(
                                                              0xff3e948e),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
