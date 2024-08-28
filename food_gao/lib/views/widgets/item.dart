import 'package:flutter/material.dart';
import 'package:food_gao/routs/app_routs.dart';
import 'package:food_gao/views/home/order_screen.dart';

import '../../services/firebase_services.dart';
import '../../utils/app_color.dart';

class RecommendedItem extends StatefulWidget {
  final String image;
  final String name;
  final String description;
  final String price;
  final List<Map<String, dynamic>> relatedProducts;

  const RecommendedItem({
    Key? key,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    this.relatedProducts = const [],
  }) : super(key: key);

  @override
  _RecommendedItemState createState() => _RecommendedItemState();
}

class _RecommendedItemState extends State<RecommendedItem> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    // Optionally, you can check if the item is already in favorites here
    // isFavorited = await AuthService().isItemFavorited(widget.image); // Hypothetical function
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        sendToPagePush(context: context, page: OrderPage(
          image: widget.image,
          name: widget.name,
          description: widget.description,
          price: widget.price,
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: ClipOval(
                    child: Image.network(widget.image, height: 80, width: 80, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 2,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        isFavorited = !isFavorited;
                      });
                      if (isFavorited) {
                        await AuthProvider().favoriteAdd(
                          widget.image, widget.name, widget.price, widget.description, context,
                        );
                      } else {
                        await AuthProvider().favoriteRemove(
                          widget.image, widget.name, context,
                        ); // Add a function to remove from favorites
                      }
                    },
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.price,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () async {
                    await AuthProvider().addToCart(widget.image, widget.name, widget.price, widget.description,widget.relatedProducts,context);
                  },
                  child: CircleAvatar(
                    backgroundColor: orangeBorderColor,
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                    radius: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
