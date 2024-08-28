import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_services.dart';
import '../../utils/app_color.dart';
import '../widgets/item.dart';

class HomePage extends StatefulWidget {
  final String searchQuery;

  const HomePage({super.key, this.searchQuery = ''});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchProducts(widget.searchQuery);
    }
  }

  Future<void> _loadProductData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final products = await Provider.of<AuthProvider>(context, listen: false).fetchProducts();
      setState(() {
        allProducts = products;
        _searchProducts(widget.searchQuery);
      });
    } catch (e) {
      print('Error fetching product data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getRelatedProducts(String category, List<Map<String, dynamic>> products) {
    return products.where((product) {
      return product['name'] == category && product['name'] != null;
    }).toList();
  }

  void _searchProducts(String query) {
    setState(() {
      filteredProducts = allProducts.where((product) {
        return product['name'] != null &&
            product['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPromotionSection(),
              const SizedBox(height: 40),
              _buildRecommendedSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Free Delivery For Spaghetti',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Up to 3 times per day',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(color: whiteTextColor),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/h.jpg', // Replace with your image path
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    if (filteredProducts.isEmpty) {
      return const Center(child: Text('No products available'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended for you',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'See More',
              style: TextStyle(color: blackTextColor),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            final relatedProducts = _getRelatedProducts(product['name'] ?? '', allProducts);
            return RecommendedItem(
              image: product['image'] ?? '',
              name: product['name'] ?? 'Product Name',
              description: product['description'] ?? 'Product Description',
              price: product['price'] != null
                  ? '\$${product['price']}'
                  : 'N/A',
              relatedProducts: relatedProducts,
            );
          },
        ),
      ],
    );
  }
}
