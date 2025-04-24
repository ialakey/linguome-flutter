class Item {
  String? pageId;
  final String word;
  final String pos;
  final int wordPosRank;
  final String definition;
  final String status;

  Item({
    this.pageId,
    required this.word,
    required this.pos,
    required this.wordPosRank,
    required this.definition,
    required this.status
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      pageId: json['pageId'].toString() ?? '',
      word: json['word'].toString() ?? '',
      pos: json['pos'].toString() ?? '',
      wordPosRank: json['wordPosRank'] as int? ?? 0,
      definition: json['definition'].toString() ?? '',
      status: json['status'].toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageId': pageId,
      'word': word,
      'pos': pos,
      'wordPosRank': wordPosRank,
      'definition': definition,
      'status': status
    };
  }
}