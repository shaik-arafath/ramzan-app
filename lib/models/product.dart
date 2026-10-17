class Product {

  final String id;

  final String name;

  final String description;

  final double price;

  final String imageUrl;

  final String category;

  final int stock;

  final double rating;



  Product({

    required this.id,

    required this.name,

    required this.description,

    required this.price,

    required this.imageUrl,

    required this.category,

    this.stock = 10,

    this.rating = 4.5,

  });



  factory Product.fromJson(Map<String, dynamic> json) {

    return Product(

      id: json['id'] as String,

      name: json['name'] as String,

      description: json['description'] as String,

      price: (json['price'] as num).toDouble(),

      imageUrl: json['imageUrl'] as String,

      category: json['category'] as String,

      stock: json['stock'] as int? ?? 10,

      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,

    );

  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      stock: map['stock'] as int? ?? 10,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'name': name,

      'description': description,

      'price': price,

      'imageUrl': imageUrl,

      'category': category,

      'stock': stock,

      'rating': rating,

    };

  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
    };
  }

}

