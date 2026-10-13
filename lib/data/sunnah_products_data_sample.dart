import '../models/sunnah_product.dart';

class SunnahProductsData {
  static List<SunnahProduct> getAllProducts() {
    return [
      // 🌴 QUR'ANIC FOODS - SAMPLE PRODUCTS FOR FASTER DEVELOPMENT
      // Dates
      SunnahProduct(
        id: 'dates-ajwa',
        name: 'Ajwa Dates',
        category: 'Qur\'anic Foods',
        subcategory: 'Dates',
        price: 29.99,
        imageUrl: 'assets/icons/1.png',
        description: 'Premium Ajwa dates from Madinah',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari & Muslim: "Whoever eats seven Ajwa dates in the morning will not be harmed by poison or magic that day."',
        stock: 50,
        rating: 4.9,
      ),
      SunnahProduct(
        id: 'dates-medjool',
        name: 'Medjool Dates',
        category: 'Qur\'anic Foods',
        subcategory: 'Dates',
        price: 24.99,
        imageUrl: 'assets/icons/2.jpg',
        description: 'Large, sweet Medjool dates',
        islamicBasis: 'Qur\'an',
        evidence: 'Qur\'an 19:25: "And shake the trunk of the palm tree toward you; it will drop upon you ripe, tender dates."',
        stock: 75,
        rating: 4.8,
      ),
      // Honey
      SunnahProduct(
        id: 'honey-sidr',
        name: 'Sidr Honey',
        category: 'Qur\'anic Foods',
        subcategory: 'Honey',
        price: 39.99,
        imageUrl: 'assets/icons/3.jpg',
        description: 'Premium Sidr honey',
        islamicBasis: 'Qur\'an',
        evidence: 'Qur\'an 16:68-69: "And your Lord inspired to the bee..."',
        stock: 40,
        rating: 4.9,
      ),
      SunnahProduct(
        id: 'honey-yemeni-sidr',
        name: 'Yemeni Sidr Honey',
        category: 'Qur\'anic Foods',
        subcategory: 'Honey',
        price: 59.99,
        imageUrl: 'assets/icons/4.png',
        description: 'Authentic Yemeni Sidr honey',
        islamicBasis: 'Qur\'an',
        evidence: 'Qur\'an 16:68-69: "And your Lord inspired to the bee..."',
        stock: 25,
        rating: 5.0,
      ),
      // Olive Oil
      SunnahProduct(
        id: 'olive-oil-extra-virgin',
        name: 'Extra Virgin Olive Oil',
        category: 'Qur\'anic Foods',
        subcategory: 'Olive Oil',
        price: 19.99,
        imageUrl: 'assets/icons/5.png',
        description: 'Premium extra virgin olive oil',
        islamicBasis: 'Qur\'an',
        evidence: 'Qur\'an 24:35: "Allah is the Light of the heavens and the earth...like a lamp within an olive..."',
        stock: 80,
        rating: 4.8,
      ),
      SunnahProduct(
        id: 'olive-oil-palestinian',
        name: 'Palestinian Olive Oil',
        category: 'Qur\'anic Foods',
        subcategory: 'Olive Oil',
        price: 28.99,
        imageUrl: 'assets/icons/6.png',
        description: 'Authentic Palestinian olive oil',
        islamicBasis: 'Qur\'an',
        evidence: 'Qur\'an 23:20: "And [We brought forth] a tree issuing from Mount Sinai..."',
        stock: 40,
        rating: 4.9,
      ),
      // Black Seed
      SunnahProduct(
        id: 'blackseed-oil',
        name: 'Black Seed Oil',
        category: 'Prophetic Foods',
        subcategory: 'Black Seed',
        price: 18.99,
        imageUrl: 'assets/icons/7.jpg',
        description: 'Pure black seed oil',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari & Muslim: "Use black seed, for it contains a cure for every disease except death."',
        stock: 75,
        rating: 4.9,
      ),
      SunnahProduct(
        id: 'blackseed-cold-pressed',
        name: 'Cold-Pressed Black Seed Oil',
        category: 'Prophetic Foods',
        subcategory: 'Black Seed',
        price: 24.99,
        imageUrl: 'assets/icons/8.jpg',
        description: 'Cold-pressed black seed oil',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari & Muslim: "Use black seed, for it contains a cure for every disease except death."',
        stock: 50,
        rating: 4.9,
      ),
      // Barley/Talbina
      SunnahProduct(
        id: 'talbina-mix',
        name: 'Talbina Mix',
        category: 'Prophetic Foods',
        subcategory: 'Barley',
        price: 14.99,
        imageUrl: 'assets/icons/9.jpg',
        description: 'Traditional talbina mix',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari & Muslim: "Talbina gives comfort to the sick and lessens grief."',
        stock: 60,
        rating: 4.8,
      ),
      SunnahProduct(
        id: 'talbina-instant',
        name: 'Instant Talbina',
        category: 'Prophetic Foods',
        subcategory: 'Barley',
        price: 16.99,
        imageUrl: 'assets/icons/download.jpg',
        description: 'Quick-prep instant talbina',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari & Muslim: "Talbina gives comfort to the sick and lessens grief."',
        stock: 50,
        rating: 4.7,
      ),
      // Miswak
      SunnahProduct(
        id: 'miswak-premium',
        name: 'Premium Miswak',
        category: 'Prophetic Hygiene',
        subcategory: 'Miswak',
        price: 5.99,
        imageUrl: 'assets/icons/download (1).jpg',
        description: 'Premium quality miswak',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Multiple hadith: "Were it not that I would overburden my Ummah, I would have ordered them to use the miswak."',
        stock: 150,
        rating: 4.8,
      ),
      SunnahProduct(
        id: 'miswak-pack',
        name: 'Miswak Pack (5pcs)',
        category: 'Prophetic Hygiene',
        subcategory: 'Miswak',
        price: 14.99,
        imageUrl: 'assets/icons/png1.png',
        description: 'Pack of 5 miswaks',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Multiple hadith: "Were it not that I would overburden my Ummah, I would have ordered them to use the miswak."',
        stock: 100,
        rating: 4.7,
      ),
      // Musk
      SunnahProduct(
        id: 'musk-white',
        name: 'White Musk',
        category: 'Islamic Fragrance',
        subcategory: 'Musk',
        price: 29.99,
        imageUrl: 'assets/icons/png2.png',
        description: 'Pure white musk',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari: "The example of the good companion is the seller of musk."',
        stock: 60,
        rating: 4.8,
      ),
      SunnahProduct(
        id: 'musk-attar',
        name: 'Musk Attar',
        category: 'Islamic Fragrance',
        subcategory: 'Musk',
        price: 24.99,
        imageUrl: 'assets/icons/png3.png',
        description: 'Traditional musk attar',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Bukhari: "The example of the good companion is the seller of musk."',
        stock: 70,
        rating: 4.7,
      ),
      // Oud
      SunnahProduct(
        id: 'oud-oil',
        name: 'Oud Oil',
        category: 'Islamic Fragrance',
        subcategory: 'Oud',
        price: 49.99,
        imageUrl: 'assets/icons/png13.png',
        description: 'Pure oud oil',
        islamicBasis: 'General Halal',
        evidence: 'Traditional Islamic fragrance',
        stock: 40,
        rating: 4.9,
      ),
      SunnahProduct(
        id: 'oud-attar',
        name: 'Oud Attar',
        category: 'Islamic Fragrance',
        subcategory: 'Oud',
        price: 44.99,
        imageUrl: 'assets/icons/png14.png',
        description: 'Traditional oud attar',
        islamicBasis: 'General Halal',
        evidence: 'Traditional Islamic fragrance',
        stock: 50,
        rating: 4.8,
      ),
      // Gift Boxes
      SunnahProduct(
        id: 'gift-ajwa-box',
        name: 'Ajwa Sunnah Box',
        category: 'Sunnah Gift Boxes',
        subcategory: 'Gift Boxes',
        price: 79.99,
        imageUrl: 'assets/images/products/clothing/womens/abaya.webp',
        description: '500g Ajwa + Miswak + Attar + Dua booklet',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Contains products with authentic hadith evidence',
        stock: 15,
        rating: 5.0,
      ),
      SunnahProduct(
        id: 'gift-wellness-box',
        name: 'Sunnah Wellness Box',
        category: 'Sunnah Gift Boxes',
        subcategory: 'Gift Boxes',
        price: 89.99,
        imageUrl: 'assets/images/products/clothing/mens/thobe.webp',
        description: 'Black seed oil + Honey + Olive oil + Miswak',
        islamicBasis: 'Sahih Hadith',
        evidence: 'Contains products with authentic hadith evidence',
        stock: 12,
        rating: 5.0,
      ),
      // Add more products from the full list as needed...
      // This is a sample for faster development
    ];
  }

  static List<SunnahProduct> getProductsByCategory(String category) {
    return getAllProducts().where((p) => p.category == category).toList();
  }

  static List<SunnahProduct> getProductsBySubcategory(String subcategory) {
    return getAllProducts().where((p) => p.subcategory == subcategory).toList();
  }

  static List<String> getCategories() {
    return getAllProducts()
        .map((p) => p.category)
        .toSet()
        .toList()
      ..sort();
  }

  static List<String> getSubcategories(String category) {
    return getAllProducts()
        .where((p) => p.category == category)
        .map((p) => p.subcategory)
        .toSet()
        .toList()
      ..sort();
  }

  static SunnahProduct? getProductById(String id) {
    try {
      return getAllProducts().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
