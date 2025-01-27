import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cart = {};

  Map<String, Map<String, dynamic>> get cart => _cart;

  double calculateDiscountedPrice(double price, double discount) {
    return price - (price * discount);
  }

  num getTotalCartItems() {
    return _cart.values
        .fold(0, (total, item) => total + (item['quantity'] ?? 0));
  }

  double calculateTotal() {
    return _cart.entries.fold(0.0, (total, entry) {
      final item = entry.value;
      // Use the discounted price here when calculating the total
      return total + (item['discountedPrice'] * item['quantity']);
    });
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void addItem(String name, double price, double discount) {
    double discountedPrice = calculateDiscountedPrice(price, discount);
    if (_cart.containsKey(name)) {
      _cart[name]!['quantity']++;
    } else {
      _cart[name] = {
        'name': name,
        'price': price, // Store the original price
        'discount': discount, // Store the discount rate
        'discountedPrice': discountedPrice, // Store the discounted price
        'quantity': 1,
      };
    }
    notifyListeners();
  }

  void removeItem(String name) {
    if (_cart.containsKey(name)) {
      if (_cart[name]!['quantity'] > 1) {
        _cart[name]!['quantity']--;
      } else {
        _cart.remove(name);
      }
      notifyListeners();
    }
  }
}
