import 'package:flutter/material.dart';
import 'package:food_gao/utils/app_color.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_services.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, // Removes the back icon
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search your order here',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: _searchQuery.isEmpty
                        ? const Icon(Icons.mic)
                        : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear(); // Clear the text field
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              // future: authProvider.fetchOrders(),
              future: authProvider.fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found'));
                } else {
                  // Filter the orders based on the search query
                  final filteredOrders = snapshot.data!
                      .where((order) =>
                      order['name']
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  return filteredOrders.isEmpty
                      ? const Center(child: Text('No matching orders found'))
                      : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                order['image'],
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              'Your order is  ${order['status']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                   order['name'],
                                  style: const TextStyle(
                                      color: orangeTextColor),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(Icons.star,
                                        size: 16, color: Colors.green),
                                    Icon(Icons.star,
                                        size: 16, color: Colors.green),
                                    Icon(Icons.star,
                                        size: 16, color: Colors.green),
                                    Icon(Icons.star,
                                        size: 16, color: Colors.grey),
                                    Icon(Icons.star,
                                        size: 16, color: Colors.grey),
                                    SizedBox(width: 5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider()
                        ],
                      );
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
