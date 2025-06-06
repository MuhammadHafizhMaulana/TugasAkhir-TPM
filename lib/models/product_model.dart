class Product {
  final int id;
  final String model;
  final String brand;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.model,
    required this.brand,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      model: json['model'] ?? 'Unknown',
      brand: json['model'] ?? 'No model',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

}

