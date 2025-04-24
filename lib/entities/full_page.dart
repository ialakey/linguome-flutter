import 'package:linguome/entities/item.dart';
import 'package:linguome/entities/page.dart';

class FullPage {
  final PageLinguome pageLinguome;
  final List<Item> items;

  FullPage({
    required this.pageLinguome,
    required this.items,
  });

  factory FullPage.fromJson(Map<String, dynamic> json) {
    return FullPage(
      pageLinguome: PageLinguome.fromJson(json['pageLinguome']),
      items: (json['items'] as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageLinguome': pageLinguome.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}