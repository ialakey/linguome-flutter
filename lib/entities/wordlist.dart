import 'package:linguome/entities/item.dart';

class Wordlist {
  final String id;
  final String page;
  final String createdAt;
  final List<Item> items;

  Wordlist({
    required this.id,
    required this.page,
    required this.createdAt,
    required this.items,
  });

  factory Wordlist.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] ?? '';
    final String page = json['page'].toString() ?? '';
    final String createdAt = json['createdAt'].toString() ?? '';

    final List<Map<String, dynamic>> itemsJson = (json['items'] as List<dynamic>)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    final List<Item> items = itemsJson.map((itemJson) => Item.fromJson(itemJson)).toList();

    return Wordlist(
      id: id,
      page: page,
      createdAt: createdAt,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'page': page,
      'createdAt': createdAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}