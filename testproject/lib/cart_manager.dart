import 'package:flutter/material.dart';

class CartManager {
  // Global cart storage variable tracking selection elements
  static final ValueNotifier<List<Map<String, dynamic>>> cartItems = ValueNotifier([]);

  // Append product maps securely
  static void addToCart(Map<String, dynamic> product) {
    List<Map<String, dynamic>> updatedCart = List.from(cartItems.value);
    updatedCart.add(product);
    cartItems.value = updatedCart;
  }

  // Remove elements mapping directly to item list indexing values
  static void removeFromCart(int index) {
    List<Map<String, dynamic>> updatedCart = List.from(cartItems.value);
    updatedCart.removeAt(index);
    cartItems.value = updatedCart;
  }

  // Calculate pricing data aggregates automatically
  static double get totalPrice {
    double total = 0.0;
    for (var item in cartItems.value) {
      total += double.tryParse(item['price'].toString()) ?? 0.0;
    }
    return total;
  }
}