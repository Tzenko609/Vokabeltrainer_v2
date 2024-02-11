// home_screen.dart
import 'package:flutter/material.dart';
import 'CreateUnitScreen.dart';
import 'TrainingScreen.dart';
import 'languages.dart';
import 'vocab_model.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vokabeltrainer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Hier kannst du zur Trainingsseite navigieren
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainingPackListScreen()),
                );
              },
              child: Text('Training'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Hier kannst du zur Seite zum Erstellen von Trainingseinheiten navigieren
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateUnitScreen()),
                );
              },
              child: Text('Trainingseinheit erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}