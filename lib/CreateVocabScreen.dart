import 'package:flutter/material.dart';
import 'package:vokabeltrainer_v2/AddVocabScreen.dart';
import 'languages.dart';
import 'vocab_model.dart';
import 'DatabaseHelper.dart';

class CreateVocabScreen extends StatefulWidget {
  @override
  _CreateVocabScreenState createState() => _CreateVocabScreenState();
}

class _CreateVocabScreenState extends State<CreateVocabScreen> {
  TextEditingController vocabPackNameController = TextEditingController();
  Language? sourceLanguage;
  Language? targetLanguage;
  int? vocabPackId; // Hier deklarieren

  Future<bool> saveVocabPackToDatabase() async {
    String vocabPackName = vocabPackNameController.text;
    String sourceLanguageCode = sourceLanguage?.name ?? '';
    String targetLanguageCode = targetLanguage?.name ?? '';

    if (vocabPackName.isNotEmpty && sourceLanguage != null && targetLanguage != null) {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.insertVocabPack(vocabPackName, sourceLanguageCode, targetLanguageCode);
      vocabPackId = await dbHelper.getVocabPackIdByName(vocabPackName);

      if (vocabPackId != null) {
        print('Vokabelpaket-ID gefunden: $vocabPackId');
        print('Vokabelpaket wurde in die Datenbank geschrieben');
        return true;
      } else {
        print('Vokabelpaket mit dem Namen "$vocabPackName" nicht gefunden.');
        return false;
      }
    } else {
      print('Bitte fülle alle Felder aus');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vokabelpaket erstellen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: vocabPackNameController,
              decoration: InputDecoration(labelText: 'Name des Vokabelpakets'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<Language>(
              value: sourceLanguage,
              hint: Text('Quellsprache auswählen'),
              onChanged: (Language? newValue) {
                setState(() {
                  sourceLanguage = newValue;
                });
              },
              items: languages.map<DropdownMenuItem<Language>>((Language value) {
                return DropdownMenuItem<Language>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<Language>(
              value: targetLanguage,
              hint: Text('Zielsprache auswählen'),
              onChanged: (Language? newValue) {
                setState(() {
                  targetLanguage = newValue;
                });
              },
              items: languages.map<DropdownMenuItem<Language>>((Language value) {
                return DropdownMenuItem<Language>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await saveVocabPackToDatabase();
                if (success && vocabPackId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddVocabScreen(trainingsblockid: vocabPackId!),
                    ),
                  );
                } else {
                  print('Irgendwie finde ich die ID nicht oder die Operation war nicht erfolgreich');
                }
              },
              child: Text('Weiter'),
            ),
          ],
        ),
      ),
    );
  }
}