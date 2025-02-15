import 'package:flutter/material.dart';


import 'package:food_gao/utils/app_color.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('No user is signed in')),
      );
    }

    return Scaffold(
      appBar: AppBar(

        title: Text('Favorites',style: TextStyle(color: whiteTextColor),),
        backgroundColor: orangeButtonColor,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favoriteAdd')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favorites found.'));
          }

          var favoriteItems = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.8,
            ),
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              var item = favoriteItems[index];
              return ProductItem(
                name: item['name'],
                price: item['price'],
                imageUrl: item['image'],
                rating: 4.5, // You might need to add rating in Firestore if needed
              );
            },
          );
        },
      ),
    );
  }
}



class ProductItem extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final double rating;

  ProductItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('${price.toString()}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text(rating.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}