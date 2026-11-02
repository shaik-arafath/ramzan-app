class Stitcher {
  final String id;
  final String password;
  final String aadharCard;
  final String mobileNumber;
  final String address;
  final String shopAddress;
  final double shopLatitude;
  final double shopLongitude;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Stitcher({
    required this.id,
    required this.password,
    required this.aadharCard,
    required this.mobileNumber,
    required this.address,
    required this.shopAddress,
    required this.shopLatitude,
    required this.shopLongitude,
    required this.verificationStatus,
    required this.createdAt,
    this.updatedAt,
  });

  factory Stitcher.fromJson(Map<String, dynamic> json) {
    return Stitcher(
      id: json['id'] as String,
      password: json['password'] as String,
      aadharCard: json['aadhar_card'] as String,
      mobileNumber: json['mobile_number'] as String,
      address: json['address'] as String,
      shopAddress: json['shop_address'] as String,
      shopLatitude: (json['shop_latitude'] as num).toDouble(),
      shopLongitude: (json['shop_longitude'] as num).toDouble(),
      verificationStatus: json['verification_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'aadhar_card': aadharCard,
      'mobile_number': mobileNumber,
      'address': address,
      'shop_address': shopAddress,
      'shop_latitude': shopLatitude,
      'shop_longitude': shopLongitude,
      'verification_status': verificationStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Stitcher copyWith({
    String? id,
    String? password,
    String? aadharCard,
    String? mobileNumber,
    String? address,
    String? shopAddress,
    double? shopLatitude,
    double? shopLongitude,
    String? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Stitcher(
      id: id ?? this.id,
      password: password ?? this.password,
      aadharCard: aadharCard ?? this.aadharCard,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      shopAddress: shopAddress ?? this.shopAddress,
      shopLatitude: shopLatitude ?? this.shopLatitude,
      shopLongitude: shopLongitude ?? this.shopLongitude,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
