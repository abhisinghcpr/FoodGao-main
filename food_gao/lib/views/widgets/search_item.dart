class Product {
  final String image;
  final String name;
  final String description;
  final String price;

  Product({
    required this.image,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      image: data['image'] as String? ?? 'No image',
      name: data['name'] as String? ?? 'Product Name',
      description: data['description'] as String? ?? 'Product Description',
      price: data['price'] as String? ?? 'N/A',
    );
  }
}
