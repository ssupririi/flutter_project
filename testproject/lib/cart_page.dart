import 'package:flutter/material.dart';
import 'cart_manager.dart';

class CartPage extends StatelessWidget {
  final String baseUrl = 'http://10.0.2.2:3000';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shopping Cart")),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: CartManager.cartItems,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return Center(child: Text("Your cart is empty"));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        CartManager.removeFromCart(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item['name']} removed")),
                        );
                      },
                      child: ListTile(
                        leading: Image.network(
                          '$baseUrl/images/${item['image_url']}',
                          width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(Icons.image),
                        ),
                        title: Text(item['name'] ?? ''),
                        subtitle: Text("₱${item['price']}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                          onPressed: () {
                            CartManager.removeFromCart(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Price:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      "₱${CartManager.totalPrice.toStringAsFixed(2)}", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}