import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cart = {};

  Map<String, Map<String, dynamic>> get cart => _cart;

  String generateUniqueOrderId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

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

      return total + (item['discountedPrice'] * item['quantity']);
    });
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void addToCart(
      String name, int quantity, double price, double discountedPrice) {
    String orderId = generateUniqueOrderId();
    if (_cart.containsKey(name)) {
      _cart[name]!['quantity'] = (_cart[name]!['quantity'] as int) + quantity;
    } else {
      _cart[name] = {
        'orderId': orderId,
        'name': name,
        'price': price,
        'discountedPrice': discountedPrice,
        'quantity': quantity,
      };
    }
    notifyListeners();
  }

  void addItem(String name, double price, double discount) {
    double discountedPrice = calculateDiscountedPrice(price, discount);
    if (_cart.containsKey(name)) {
      _cart[name]!['quantity']++;
    } else {
      _cart[name] = {
        'name': name,
        'price': price,
        'discount': discount,
        'discountedPrice': discountedPrice,
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