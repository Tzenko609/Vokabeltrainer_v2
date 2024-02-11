import 'package:flutter/material.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'VocabListScreen.dart';

class VocabPackListScreen extends StatefulWidget {
  @override
  _VocabPackListScreenState createState() => _VocabPackListScreenState();
}

class _VocabPackListScreenState extends State<VocabPackListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alle Vokabelblöcke'),
      ),
      body: FutureBuilder<List<String>>(
        future: DatabaseHelper().getAllVocabPackNames(),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Fehler beim Laden der Vokabelblöcke');
          } else {
            List<String> vocabPackNames = snapshot.data!;

            return ListView.builder(
              itemCount: vocabPackNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(vocabPackNames[index]),
                  onTap: () {
                    // Navigiere zum VocabListScreen und übergebe die VocabPackId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabListScreen(vocabPackId: index + 1), // Index + 1, da Listenindex bei 0 beginnt
                      ),
                    );
                  },
                  // Hinzufügen des Löschen-Buttons
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      // Hier wird die Löschfunktion aufgerufen
                      await DatabaseHelper().deleteVocabPack(vocabPackNames[index]);
                      // Du könntest hier auch eine Bestätigungsdialog anzeigen oder andere Aktionen durchführen
                      // Zeige z.B. einen SnackBar an
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vokabelblock wurde gelöscht.'),
                        ),
                      );
                      // Nach dem Löschen kannst du den Bildschirm aktualisieren
                      // (nach Bedarf, abhängig davon, wie du die Aktualisierung handhaben möchtest)
                      setState(() {});
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}