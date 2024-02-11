import 'package:flutter/material.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'package:vokabeltrainer_v2/InTrainingScreen.dart';


class TrainingPackListScreen extends StatefulWidget {
  @override
  _TrainingPackListScreenState createState() => _TrainingPackListScreenState();
}

class _TrainingPackListScreenState extends State<TrainingPackListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alle Trainingsblöcke'),
      ),
      body: FutureBuilder<List<String>>(
        future: DatabaseHelper().getAllVocabPackNames(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Fehler beim Laden der Trainingsblöcke');
          } else {
            List<String> trainingPackNames = snapshot.data!;

            return ListView.builder(
              itemCount: trainingPackNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(trainingPackNames[index]),
                  onTap: () {
                    // Hier wird die Funktion zum Starten des Trainings aufgerufen
                    _startTraining(context, trainingPackNames[index]);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _startTraining(BuildContext context, String trainingPackName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wollen Sie das Training beginnen?'),
          actions: [
            TextButton(
              onPressed: () {
                // Hier wird die Funktion für das schnelle Training aufgerufen
                print('soweit komme ich');
                print(trainingPackName);
                print(context);
                _startTrainingWithVocabCount(context, trainingPackName, 5);
              },
              child: Text('Schnell (5 Vokabeln)'),
            ),
            TextButton(
              onPressed: () {
                // Hier wird die Funktion für das mittlere Training aufgerufen
                _startTrainingWithVocabCount(context, trainingPackName, 10);
              },
              child: Text('Mittel (10 Vokabeln)'),
            ),
            TextButton(
              onPressed: () {
                // Hier wird die Funktion für das lange Training aufgerufen
                _startTrainingWithVocabCount(context, trainingPackName, 20);
              },
              child: Text('Lang (20 Vokabeln)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Schließe das Dialogfenster
              },
              child: Text('Abbrechen'),
            ),
          ],
        );
      },
    );
  }



  void _startTrainingWithVocabCount(BuildContext context, String trainingPackName, int vocabCount) {
    print('Start Training with $vocabCount vocabularies for $trainingPackName');
    // Hier kannst du zur Trainingsseite navigieren und die Trainingsdaten übergeben
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingScreen(trainingPackName: trainingPackName, vocabCount: vocabCount),
      ),
    );
    print('gay');
    //Navigator.pop(context); // Schließe das Dialogfenster
  }
}