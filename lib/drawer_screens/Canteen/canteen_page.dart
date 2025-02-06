import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CanteenMenuPage extends StatefulWidget {
  @override
  _CanteenMenuPageState createState() => _CanteenMenuPageState();
}

class _CanteenMenuPageState extends State<CanteenMenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> menuItems = [];
  final Map<String, int> cart = {};

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('canteen').get();
      setState(() {
        menuItems = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'name': data['foodname'],
            'price': data['price'].toDouble(),
            'discount': data['discount'].toDouble(),
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching menu items: $e');
    }
  }

  double calculateDiscountedPrice(double price, double discount) {
    return price - (price * discount);
  }

  double calculateTotalPrice() {
    return cart.entries.fold(
      0.0,
          (total, entry) {
        final item = menuItems.firstWhere((i) => i['name'] == entry.key);
        return total +
            (calculateDiscountedPrice(item['price'], item['discount']) *
                entry.value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Canteen Menu'),
        centerTitle: true,
      ),
      body: menuItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Menu List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  final discountedPrice = calculateDiscountedPrice(
                      item['price'], item['discount']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // cart[item['name']] = (cart[item['name']] ?? 0) + 1;
                      });
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.0)),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              // Adjust for desired image aspect ratio
                              child: Image.asset(
                                'lib/assets/profile.jpg',
                                fit: BoxFit
                                    .cover, // Ensures the image scales properly
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
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Price: ₹${item['price'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Discount: ${(item['discount'] * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '₹${discountedPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Order Summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...cart.entries.map((entry) {
                    final item = menuItems
                        .firstWhere((i) => i['foodname'] == entry.key);
                    final discountedPrice = calculateDiscountedPrice(
                        item['price'], item['discount']);
                    return ListTile(
                      title: Text('${entry.key} x${entry.value}'),
                      trailing: Text(
                          '\$${(discountedPrice * entry.value).toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  Divider(),
                  Text(
                    // Dynamically calculate total price based on cart entries
                    'Total: \$${cart.entries.fold(0.0, (total, entry) {
                      final item = menuItems
                          .firstWhere((i) => i['foodname'] == entry.key);
                      final discountedPrice = calculateDiscountedPrice(
                          item['price'], item['discount']);
                      return total + (discountedPrice * entry.value);
                    }).toStringAsFixed(2)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Container(
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
                      onPressed: () {},
                      child: Text(
                        'Place Order',
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
        ],
      ),
    );
  }
}

