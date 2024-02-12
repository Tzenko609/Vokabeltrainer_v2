import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'package:vokabeltrainer_v2/VocabPackListScreen.dart';
import 'CreateVocabScreen.dart';
import 'languages.dart';
import 'CreateVocabScreen.dart'; // Stelle sicher, dass die Datei korrekt importiert ist

class CreateUnitScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingseinheit erstellen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Hier kannst du zur vorherigen Seite (Startscreen) zurückkehren
                Navigator.pop(context);
              },
              child: Text('Zurück zum Start'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Hier kannst du direkt zum Erstellen von Vokabeln navigieren
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateVocabScreen(),
                  ),
                );
              },
              child: Text('Neuen Trainingsblock erstellen'),
            ),
            ElevatedButton(
              onPressed: () async {
                DatabaseHelper dbHelper = DatabaseHelper();
                //await dbHelper.createAdditionalTables();
                //print("erstellt");
                //await dbHelper.vokabeltest('testpaket',5);
                await dbHelper.printTableContents('VocabGepruefterStapel');
              },
              child: Text('Print Table Contents'),
            ),
            ElevatedButton(
              onPressed: () async {
                DatabaseHelper dbHelper = DatabaseHelper();
                await dbHelper.printTableStructure();
              },
              child: Text('Print Table Structure'),
            ),
            ElevatedButton(
              onPressed: () {
                // Hier kannst du direkt zum Erstellen von Vokabeln navigieren
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VocabPackListScreen(),
                  ),
                );
              },
              child: Text('alle Vokabelblöcke '),
            ),
          ],
        ),
      ),
    );
  }
}