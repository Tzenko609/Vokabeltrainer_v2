// training_manager.dart
import 'vocab_model.dart';

class TrainingManager {
  List<Vocab> mainStack = [];
  List<Vocab> trainingStack = [];
  List<Vocab> learnedStack = [];
  List<Vocab> extendedStack = [];

  void initializeStack(List<Vocab> vocabList) {
    mainStack.addAll(vocabList);
  }

  void startTraining(int batchSize, {bool reverseOrder = false}) {
    // Logik für das Training hier einfügen
  }

// Weitere Methoden für Stapelmanagement hinzufügen
}