class Product {
  final String? id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String userId;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.userId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Convert Product to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  // Create Product from Firestore document
  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}