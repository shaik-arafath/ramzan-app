class Bayan {
  final String id;
  final String title;
  final String description;
  final String videoUrl;

  Bayan({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
  });

  factory Bayan.fromMap(Map<String, dynamic> map) {
    return Bayan(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? 'Daily Bayan',
      description: map['description'] as String? ?? '',
      videoUrl: map['video_url'] as String? ?? '',
    );
  }
}
