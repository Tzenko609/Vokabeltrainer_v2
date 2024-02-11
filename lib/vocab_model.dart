// vocab_model.dart
class Vocabulary {
  int id;
  String term;
  String description;
  String translation;

  Vocabulary({
    required this.id,
    required this.term,
    required this.description,
    required this.translation,
  });

  // Konstruktor für das Erstellen eines Vocabulary-Objekts aus einer Map
  Vocabulary.fromMap(Map<String, dynamic> map)
      : id = map['id'] as int,
        term = map['term'] as String,
        description = map['description'] as String,
        translation = map['translation'] as String;

// Weitere Methoden oder Eigenschaften des Vocabulary-Modells können hier hinzugefügt werden
}