class Masjid {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String country;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String? imageUrl;
  final String? fajrTime;
  final String? dhuhrTime;
  final String? asrTime;
  final String? maghribTime;
  final String? ishaTime;
  final String? jummahTime;
  final String? description;
  final List<String>? facilities;
  final DateTime createdAt;
  final DateTime updatedAt;

  Masjid({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.country = 'India',
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.imageUrl,
    this.fajrTime,
    this.dhuhrTime,
    this.asrTime,
    this.maghribTime,
    this.ishaTime,
    this.jummahTime,
    this.description,
    this.facilities,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Masjid.fromMap(Map<String, dynamic> map) {
    return Masjid(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String?,
      state: map['state'] as String?,
      country: map['country'] as String? ?? 'India',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      phone: map['phone'] as String?,
      website: map['website'] as String?,
      imageUrl: map['image_url'] as String?,
      fajrTime: map['fajr_time'] as String?,
      dhuhrTime: map['dhuhr_time'] as String?,
      asrTime: map['asr_time'] as String?,
      maghribTime: map['maghrib_time'] as String?,
      ishaTime: map['isha_time'] as String?,
      jummahTime: map['jummah_time'] as String?,
      description: map['description'] as String?,
      facilities: (map['facilities'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    final map = {
      'name': name,
      'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (imageUrl != null) 'image_url': imageUrl,
      if (fajrTime != null) 'fajr_time': fajrTime,
      if (dhuhrTime != null) 'dhuhr_time': dhuhrTime,
      if (asrTime != null) 'asr_time': asrTime,
      if (maghribTime != null) 'maghrib_time': maghribTime,
      if (ishaTime != null) 'isha_time': ishaTime,
      if (jummahTime != null) 'jummah_time': jummahTime,
      if (description != null) 'description': description,
      if (facilities != null) 'facilities': facilities,
    };

    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  // Calculate distance from current location in kilometers
  double distanceFrom(double userLat, double userLng) {
    const double earthRadius = 6371; // in kilometers
    final double dLat = _toRadians(latitude - userLat);
    final double dLng = _toRadians(longitude - userLng);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        (dLat).cos() * (userLat).cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    final double c = 2 * (a.sqrt()).asin();
    
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * 3.141592653589793 / 180;
  }
}
