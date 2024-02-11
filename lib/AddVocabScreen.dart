import 'package:flutter/material.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'vocab_model.dart';

class AddVocabScreen extends StatefulWidget {
  final int trainingsblockid;

  AddVocabScreen({required this.trainingsblockid});

  @override
  _AddVocabScreenState createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  TextEditingController termController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController translationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('Trainingsblock ID erhalten: ${widget.trainingsblockid}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vokabel hinzufügen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: termController,
              decoration: InputDecoration(labelText: 'Vokabel'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Beschreibung'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: translationController,
              decoration: InputDecoration(labelText: 'Übersetzung'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Hier kannst du die Logik implementieren, um die Vokabel zu speichern
                String term = termController.text;
                String description = descriptionController.text;
                String translation = translationController.text;

                if (term.isNotEmpty && description.isNotEmpty && translation.isNotEmpty) {
                  DatabaseHelper dbHelper = DatabaseHelper();
                  await dbHelper.insertVocabulary(term, description, translation);

                  // Holen Sie sich die ID der gerade eingefügten Vokabel
                  int? vocabId = await dbHelper.getVocabIdByTermAndTranslation(term, translation);

                  // Verknüpfe das Vokabel mit dem Vokabelpaket
                  if (vocabId != null && widget.trainingsblockid != null) {
                    await dbHelper.linkVocabToVocabPack(vocabId, widget.trainingsblockid);
                  }

                  // Hier kannst du weitere Aktionen durchführen, nachdem die Vokabel in die Datenbank geschrieben wurde
                  print('Vokabel wurde in die Datenbank geschrieben');

                  // Hier kannst du zur nächsten Seite navigieren (falls vorhanden)
                  // Beispiel: Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
                } else {
                  // Hier kannst du eine Fehlermeldung anzeigen, wenn nicht alle erforderlichen Felder ausgefüllt sind
                  print('Bitte fülle alle Felder aus');
                }
              },
              child: Text('Vokabel hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}