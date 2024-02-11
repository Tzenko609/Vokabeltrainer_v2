import 'package:flutter/material.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'vocab_model.dart';

class VocabListScreen extends StatefulWidget {
  final int vocabPackId;

  VocabListScreen({required this.vocabPackId});

  @override
  _VocabListScreenState createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vokabeln im Vokabelblock'),
      ),
      body: FutureBuilder<List<Vocabulary>>(
        future: DatabaseHelper().getVocabulariesByPackId(widget.vocabPackId),
        builder: (context, AsyncSnapshot<List<Vocabulary>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
            return Text('Keine Vokabeln gefunden.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].term),
                  subtitle: Text(snapshot.data![index].translation),
                  // Hinzufügen des Bearbeiten- und Löschen-Buttons
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Hier wird die Funktion zum Bearbeiten der Vokabel aufgerufen
                          _showEditDialog(context, snapshot.data![index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Hier wird die Funktion zum Löschen der Vokabel aufgerufen
                          _deleteVocabulary(context, snapshot.data![index]);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      // Füge den Floating Action Button hinzu
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Hier wird die Funktion zum Hinzufügen einer neuen Vokabel aufgerufen
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Funktion zum Anzeigen des Dialogs zum Bearbeiten der Vokabel
  void _showEditDialog(BuildContext context, Vocabulary vocabulary) {
    TextEditingController termController = TextEditingController(
        text: vocabulary.term);
    TextEditingController descriptController = TextEditingController(
        text: vocabulary.description);
    TextEditingController translationController = TextEditingController(
        text: vocabulary.translation);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vokabel bearbeiten'),
          content: Column(
            children: [
              TextField(controller: termController,
                  decoration: InputDecoration(labelText: 'Vokabelnname')),
              TextField(controller: descriptController,
                  decoration: InputDecoration(labelText: 'Beschreibung')),
              TextField(controller: translationController,
                  decoration: InputDecoration(labelText: 'Übersetzung')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                // Hier wird die Funktion zum Aktualisieren der Vokabel aufgerufen
                await DatabaseHelper().updateVocabulary(
                  vocabulary.id,
                  termController.text,
                  descriptController.text, // Beschreibung unverändert lassen
                  translationController.text,
                );
                Navigator.pop(context);
                // Zeige einen SnackBar für erfolgreiche Aktualisierung an
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vokabel wurde aktualisiert.'),
                  ),
                );
                // Aktualisiere den Bildschirm nach der Änderung
                setState(() {});
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  // Funktion zum Anzeigen des Dialogs zum Hinzufügen einer neuen Vokabel
  void _showAddDialog(BuildContext context) {
    TextEditingController termController = TextEditingController();
    TextEditingController descriptController = TextEditingController();
    TextEditingController translationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Neue Vokabel hinzufügen'),
          content: Column(
            children: [
              TextField(controller: termController,
                  decoration: InputDecoration(labelText: 'Vokabelnname')),
              TextField(controller: descriptController,
                  decoration: InputDecoration(labelText: 'Beschreibung')),
              TextField(controller: translationController,
                  decoration: InputDecoration(labelText: 'Übersetzung')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () async {
                // Hier wird die Funktion zum Hinzufügen einer neuen Vokabel aufgerufen
                await _addVocabulary(
                  termController.text,
                  descriptController.text,
                  translationController.text,
                );
                Navigator.pop(context);
                // Zeige einen SnackBar für erfolgreiche Hinzufügung an
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vokabel wurde hinzugefügt.'),
                  ),
                );
                // Aktualisiere den Bildschirm nach der Änderung
                setState(() {});
              },
              child: Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  // Funktion zum Löschen der Vokabel
  Future<void> _deleteVocabulary(BuildContext context,
      Vocabulary vocabulary) async {
    await DatabaseHelper().deleteVocabulary(vocabulary.id);
    // Zeige z.B. einen SnackBar an
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vokabel wurde gelöscht.'),
      ),
    );
    // Hier kannst du den Bildschirm aktualisieren, wenn gewünscht
    setState(() {});
  }


// Funktion zum Hinzufügen einer neuen Vokabel
  Future<void> _addVocabulary(String term, String description,
      String translation) async {
    // Hier wird die Funktion zum Hinzufügen der Vokabel aufgerufen
    await DatabaseHelper().insertVocabulary(term, description, translation);
    // Holen Sie sich die ID der gerade eingefügten Vokabel
    int? vocabId = await DatabaseHelper().getVocabIdByTermAndTranslation(term, translation);

    // Verknüpfe das Vokabel mit dem Vokabelpaket
    if (vocabId != null && widget.vocabPackId != null) {
      await DatabaseHelper().linkVocabToVocabPack(vocabId, widget.vocabPackId);
    }
  }
}
