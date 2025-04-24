class PageLinguome {
  final String id;
  final String user;
  final String createdAt;
  final String updatedAt;
  final String title;
  final String text;

  PageLinguome({
    required this.id,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.text,
  });

  factory PageLinguome.fromJson(Map<String, dynamic> json) {
    return PageLinguome(
      id: json['id'] ?? '',
      user: json['user']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'title': title,
      'text': text,
    };
  }
}