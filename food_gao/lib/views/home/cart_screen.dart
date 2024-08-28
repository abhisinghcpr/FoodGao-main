import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routs/app_routs.dart';
import '../../services/firebase_services.dart';
import '../../utils/app_color.dart';
import 'order_screen.dart'; // Make sure this import is correct

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: whiteTextColor),
        title: const Text(
          'Cart Summary',
          style: TextStyle(color: whiteTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: orangeTextColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: authProvider.getCartItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text('Loading'));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading cart items'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items in cart'));
                } else {
                  return ProductSummary(cartItems: snapshot.data!);
                }
              },
            );
          },
        ),
      ),
    );
  }
}


class ProductSummary extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  ProductSummary({required this.cartItems});

  @override
  _ProductSummaryState createState() => _ProductSummaryState();
}

class _ProductSummaryState extends State<ProductSummary> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ListView.builder(
        itemCount: widget.cartItems.length,
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          int quantity = item['quantity'] ?? 1;

          return Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.network(item['image'], width: 70, height: 70, fit: BoxFit.cover),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text('Price: ${item['price']}',
                              style: const TextStyle(fontSize: 16, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                                widget.cartItems[index]['quantity'] = quantity;
                              });
                              authProvider.updateCartItemQuantity(item['id'], quantity);
                            }
                          },
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              quantity++;
                              widget.cartItems[index]['quantity'] = quantity;
                            });
                            authProvider.updateCartItemQuantity(item['id'], quantity);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          widget.cartItems.removeAt(index);
                        });
                        authProvider.removeItemFromCart(item['id']);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        sendToPagePush(
                          context: context,
                          page: OrderPage(
                            image: item['image'],
                            name: item['name'],
                            description: item['description'],
                            price: item['price'],
                            relatedProducts: (item['relatedProducts'] as List<dynamic>).cast<Map<String, dynamic>>(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.flash_on_outlined,
                        color: Colors.grey,
                      ),
                      label: const Text(
                        'Buy this now',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        );
    }
}
