// main.dart
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:vokabeltrainer_v2/DatabaseHelper.dart';
import 'home_screen.dart';

void main() async {
  // FFI Initialization (Not needed for sqflite_common_ffi_web)
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabeltrainer',
      home: HomeScreen(),
    );
  }
}