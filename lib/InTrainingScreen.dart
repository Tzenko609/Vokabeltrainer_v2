import 'package:flutter/material.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'package:vokabeltrainer_v2/vocab_model.dart';
import 'vocab_model.dart';

class TrainingScreen extends StatefulWidget {
  final String trainingPackName;
  final int vocabCount;

  TrainingScreen({required this.trainingPackName, required this.vocabCount});

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  late List<Vocabulary> vocabularies;
  int currentIndex = 0;
  TextEditingController translationController = TextEditingController();


  @override
  void initState() {
    print('TrainingScreen - initState');
    super.initState();
    vocabularies = []; // Initialisiere das Feld hier
    _loadVocabularies();
  }

  void _loadVocabularies() async {
    print('TrainingScreen - Loading vocabularies for training');
    List<Vocabulary> loadedVocabularies = await DatabaseHelper()
        .getVocabulariesForTesting(widget.trainingPackName, widget.vocabCount);

    setState(() {
      vocabularies = loadedVocabularies;
      print('vokabeln geladen');
      print(vocabularies);
    });
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Richtig!' : 'Falsch!'),
          content: isCorrect
              ? Text('Die Übersetzung ist korrekt.')
              : Text('Die Übersetzung ist falsch. Die richtige Antwort ist: ${vocabularies[currentIndex].translation}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _nextVocabulary();
              },
              child: Text('Weiter'),
            ),
          ],
        );
      },
    );
  }

  void _nextVocabulary() {
    setState(() {
      currentIndex++;
      translationController.clear();
    });

    if (currentIndex < vocabularies.length) {
      // Zeige das nächste Vokabel an
    } else {
      // Training abgeschlossen
      _completeTraining();
    }
  }

  void _completeTraining() async {
    bool isTrainingComplete = await DatabaseHelper().isTrainingComplete(widget.trainingPackName);

    if (isTrainingComplete) {
      _showTrainingCompleteDialog();
    } else {
      // Hier könntest du den Benutzer fragen, ob er das Training wiederholen möchte
      _showRepeatTrainingDialog();
    }
  }

  void _showTrainingCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Training erfolgreich absolviert!'),
          content: Text('Möchten Sie das Training wiederholen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließe das Dialogfenster
                _repeatTraining();
              },
              child: Text('Ja'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließe das Dialogfenster
                // Hier könntest du weitere Aktionen nach Abschluss des Trainings durchführen
              },
              child: Text('Nein'),
            ),
          ],
        );
      },
    );
  }

  void _showRepeatTrainingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Möchten Sie das Training wiederholen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließe das Dialogfenster
                _repeatTraining();
              },
              child: Text('Ja'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließe das Dialogfenster
                // Hier könntest du weitere Aktionen nach Abschluss des Trainings durchführen
              },
              child: Text('Nein'),
            ),
          ],
        );
      },
    );
  }

  void _repeatTraining() async {
    // Hier könntest du die Anzahl der Vokabeln für das nächste Training anpassen
    await DatabaseHelper().startTraining(widget.trainingPackName, widget.vocabCount);
    _loadVocabularies();
  }

  @override
  Widget build(BuildContext context) {
    print(vocabularies);
    if (vocabularies.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Training'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                vocabularies[currentIndex].term,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: translationController,
                decoration: InputDecoration(labelText: 'Übersetzung'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  String userTranslation = translationController.text.trim().toLowerCase();
                  String correctTranslation = vocabularies[currentIndex].translation.trim().toLowerCase();
                  bool isCorrect = userTranslation == correctTranslation;

                  _showResultDialog(isCorrect);

                  // Hier wird die Funktion zum Aktualisieren der Trainingsergebnisse aufgerufen
                  DatabaseHelper().updateTrainingResults(vocabularies[currentIndex].id, isCorrect);
                },
                child: Text('Überprüfen'),
              ),
            ],
          ),
        ),
      );
    }
  }
}