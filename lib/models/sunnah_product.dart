class SunnahProduct {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final double price;
  final String imageUrl;
  final String description;
  final String islamicBasis;
  final String evidence;
  final int stock;
  final double rating;

  SunnahProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.islamicBasis,
    required this.evidence,
    required this.stock,
    required this.rating,
  });

  // Islamic basis options
  static const String quran = 'Qur\'an';
  static const String sahihHadith = 'Sahih Hadith';
  static const String otherHadith = 'Other Hadith';
  static const String generalHalal = 'General Halal';
  static const String noBasis = 'No specific textual basis';

  // Get confidence level based on Islamic basis
  String get confidenceLevel {
    switch (islamicBasis) {
      case quran:
        return 'High - Qur\'anic Evidence';
      case sahihHadith:
        return 'High - Sahih Hadith';
      case otherHadith:
        return 'Medium - Other Hadith';
      case generalHalal:
        return 'Low - General Halal';
      default:
        return 'No Evidence';
    }
  }

  // Get color for confidence level
  String get confidenceColor {
    switch (islamicBasis) {
      case quran:
      case sahihHadith:
        return '#10B981'; // Green
      case otherHadith:
        return '#F59E0B'; // Orange
      case generalHalal:
        return '#6B7280'; // Gray
      default:
        return '#EF4444'; // Red
    }
  }
}
