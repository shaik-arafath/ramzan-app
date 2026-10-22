class Wazifa {
  final String id;
  final String title;
  final String category;
  final String description;
  final String? time;
  final String? namaz;
  final String? dua;
  final String? ziker;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wazifa({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.time,
    this.namaz,
    this.dua,
    this.ziker,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wazifa.fromMap(Map<String, dynamic> map) {
    return Wazifa(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      time: map['time'] as String?,
      namaz: map['namaz'] as String?,
      dua: map['dua'] as String?,
      ziker: map['ziker'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'time': time,
      'namaz': namaz,
      'dua': dua,
      'ziker': ziker,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Wazifa copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? time,
    String? namaz,
    String? dua,
    String? ziker,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wazifa(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      time: time ?? this.time,
      namaz: namaz ?? this.namaz,
      dua: dua ?? this.dua,
      ziker: ziker ?? this.ziker,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
