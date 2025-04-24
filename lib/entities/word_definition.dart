class WordDefinition {
  final String definition;
  final String lexDomain;
  final List<String> synonyms;
  final int? cocaBand;
  final String? cocaRank;

  WordDefinition(this.definition, this.lexDomain, this.synonyms, {this.cocaBand, this.cocaRank});

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'lexDomain': lexDomain,
      'synonyms': synonyms,
      'freq': {
        'cocaBand': cocaBand,
        'cocaRank': cocaRank,
      }
    };
  }

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    final String definition = json['definition'] != null ? json['definition'] as String : '';
    final String lexDomain = json['lexDomain'] != null ? json['lexDomain'] as String : '';
    final List<dynamic>? synonymsJson = json['synonyms'];
    final List<String> synonyms = synonymsJson != null && synonymsJson.isNotEmpty
        ? List<String>.from(synonymsJson.where((synonym) => synonym != null))
        : [];

    final Map<String, dynamic>? freqJson = json['freq'];
    final int? cocaBand = freqJson != null ? freqJson['cocaBand'] as int? : null;
    final String? cocaRank = freqJson != null ? freqJson['cocaRank'] as String? : null;

    return WordDefinition(
      definition,
      lexDomain,
      synonyms,
      cocaBand: cocaBand,
      cocaRank: cocaRank,
    );
  }
}