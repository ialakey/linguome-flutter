class WordVocabulary {
  final String word;
  final String pos;
  final String definition;
  final int band;
  final int rank;
  final String status;
  final String? dateAdded;

  WordVocabulary({
    required this.word,
    required this.pos,
    required this.definition,
    required this.band,
    required this.rank,
    required this.status,
    this.dateAdded,
  });

  factory WordVocabulary.fromJson(Map<String, dynamic> json) {
    return WordVocabulary(
      word: json['word'] ?? '',
      pos: json['pos'] ?? '',
      definition: json['definition'] ?? '',
      band: json['band'] ?? 0,
      rank: json['rank'] ?? 0,
      status: json['status'] ?? 'new',
      dateAdded: json['dateAdded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'pos': pos,
      'definition': definition,
      'band': band,
      'rank': rank,
      'status': status,
      'dateAdded': dateAdded,
    };
  }
}