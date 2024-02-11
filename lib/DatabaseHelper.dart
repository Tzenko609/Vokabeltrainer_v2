// DatabaseHelper.dart
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:vokabeltrainer_v2/vocab_model.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {

    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // FFI Initialization (Not needed for sqflite_common_ffi_web)
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;


    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'vokabeltrainer.db');
    print('Database Path: $path');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE VocabPacks (
        id INTEGER PRIMARY KEY,
        name TEXT,
        sourceLanguage TEXT,
        targetLanguage TEXT
      );

      CREATE TABLE Vocabularies (
        id INTEGER PRIMARY KEY,
        term TEXT,
        description TEXT
      );

      CREATE TABLE VocabStammblock (
        id INTEGER PRIMARY KEY,
        vocabPackId INTEGER,
        vocabularyId INTEGER,
        FOREIGN KEY (vocabPackId) REFERENCES VocabPacks (id),
        FOREIGN KEY (vocabularyId) REFERENCES Vocabularies (id)
      );

      CREATE TABLE VocabTrainingBlock (
        id INTEGER PRIMARY KEY,
        vocabPackId INTEGER,
        vocabularyId INTEGER,
        FOREIGN KEY (vocabPackId) REFERENCES VocabPacks (id),
        FOREIGN KEY (vocabularyId) REFERENCES Vocabularies (id)
      );

      CREATE TABLE VocabErweiterterStapel (
        id INTEGER PRIMARY KEY,
        vocabPackId INTEGER,
        vocabularyId INTEGER,
        FOREIGN KEY (vocabPackId) REFERENCES VocabPacks (id),
        FOREIGN KEY (vocabularyId) REFERENCES Vocabularies (id)
      );

      CREATE TABLE VocabGepruefterStapel (
        id INTEGER PRIMARY KEY,
        vocabPackId INTEGER,
        vocabularyId INTEGER,
        FOREIGN KEY (vocabPackId) REFERENCES VocabPacks (id),
        FOREIGN KEY (vocabularyId) REFERENCES Vocabularies (id)
      );
    ''');
  }

  Future<void> printTableContents(String tableName) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('SELECT * FROM $tableName');
    print('Table: $tableName');
    print(result);
  }

  Future<void> printTableStructure() async {
    Database db = await database;

    List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );

    for (Map<String, dynamic> table in tables) {
      String tableName = table['name'];
      print('Table: $tableName');

      List<Map<String, dynamic>> columns = await db.rawQuery(
        "PRAGMA table_info($tableName);",
      );

      for (Map<String, dynamic> column in columns) {
        print('  ${column['name']} ${column['type']}');
      }

      print('\n');
    }
  }

  Future<int> insertVocabPack(String name, String sourceLanguage, String targetLanguage) async {
    Database db = await database;
    int vocabPackId = await db.insert('VocabPacks', {
      'name': name,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
    });
    return vocabPackId;
  }

  Future<void> insertVocabulary(String term, String description, String translation) async {
    final Database db = await database;
    await db.insert(
      'Vocabularies',
      {
        'term': term,
        'description': description,
        'translation': translation,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getVocabPackIdByName(String name) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('VocabPacks',
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [name]);

    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    } else {
      return null;
    }
  }

  Future<int?> getVocabIdByTermAndTranslation(String term, String translation) async {
    final Database db = await database;

    List<Map<String, dynamic>> result = await db.query('Vocabularies',
        columns: ['id'],
        where: 'term = ? AND translation = ?',
        whereArgs: [term, translation]);

    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    } else {
      return null;
    }
  }

  Future<void> linkVocabToVocabPack(int vocabId, int vocabPackId) async {
    final Database db = await database;

    await db.insert(
      'VocabStammblock',
      {
        'vocabPackId': vocabPackId,
        'vocabularyId': vocabId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getAllVocabPackNames() async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('VocabPacks', columns: ['name']);

    List<String> vocabPackNames = result.map((map) => map['name'].toString()).toList();
    return vocabPackNames;
  }

  Future<List<Vocabulary>> getVocabulariesByPackId(int vocabPackId) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('VocabStammblock',
        columns: ['vocabularyId'],
        where: 'vocabPackId = ?',
        whereArgs: [vocabPackId]);

    List<int> vocabIds = result.map<int>((map) => map['vocabularyId'] as int).toList();

    List<Map<String, dynamic>> vocabResult = await db.query('Vocabularies',
        where: 'id IN (${vocabIds.join(', ')})');

    List<Vocabulary> vocabularies = vocabResult
        .map<Vocabulary>((map) => Vocabulary.fromMap(map))
        .toList();

    return vocabularies;
  }

  Future<void> updateVocabulary(int vocabId, String term, String description, String translation) async {
    final Database db = await database;

    await db.update(
      'Vocabularies',
      {
        'term': term,
        'description': description,
        'translation': translation,
      },
      where: 'id = ?',
      whereArgs: [vocabId],
    );
  }

  Future<void> deleteVocabPack(String name) async {
    final Database db = await database;

    // Holen Sie sich die VocabPackId anhand des Namens
    int? vocabPackId = await getVocabPackIdByName(name);

    if (vocabPackId != null) {
      // Holen Sie sich die zugehörigen vocabularyId-Werte aus VocabStammblock
      List<Map<String, dynamic>> vocabIdsResult = await db.query('VocabStammblock',
          columns: ['vocabularyId'],
          where: 'vocabPackId = ?',
          whereArgs: [vocabPackId]);

      List<int> vocabIdsToDelete = vocabIdsResult.map<int>((map) => map['vocabularyId'] as int).toList();

      // Löschen Sie alle Verbindungen in VocabStammblock
      await db.delete('VocabStammblock', where: 'vocabPackId = ?', whereArgs: [vocabPackId]);

      // Löschen Sie alle Verbindungen in VocabTrainingBlock
      await db.delete('VocabTrainingBlock', where: 'vocabPackId = ?', whereArgs: [vocabPackId]);

      // Löschen Sie alle Verbindungen in VocabErweiterterStapel
      await db.delete('VocabErweiterterStapel', where: 'vocabPackId = ?', whereArgs: [vocabPackId]);

      // Löschen Sie alle Verbindungen in VocabGepruefterStapel
      await db.delete('VocabGepruefterStapel', where: 'vocabPackId = ?', whereArgs: [vocabPackId]);

      // Löschen Sie alle Vokabeln in Vocabularies, die zum Vokabelblock gehören
      await db.delete('Vocabularies', where: 'id IN (${vocabIdsToDelete.join(', ')})');

      // Löschen Sie den Vokabelblock selbst
      await db.delete('VocabPacks', where: 'id = ?', whereArgs: [vocabPackId]);
    }
  }

  Future<void> deleteVocabulary(int vocabularyId) async {
    final Database db = await database;

    // Löschen Sie alle Verbindungen in VocabStammblock
    await db.delete('VocabStammblock', where: 'vocabularyId = ?', whereArgs: [vocabularyId]);

    // Löschen Sie alle Verbindungen in VocabTrainingBlock
    await db.delete('VocabTrainingBlock', where: 'vocabularyId = ?', whereArgs: [vocabularyId]);

    // Löschen Sie alle Verbindungen in VocabErweiterterStapel
    await db.delete('VocabErweiterterStapel', where: 'vocabularyId = ?', whereArgs: [vocabularyId]);

    // Löschen Sie alle Verbindungen in VocabGepruefterStapel
    await db.delete('VocabGepruefterStapel', where: 'vocabularyId = ?', whereArgs: [vocabularyId]);

    // Löschen Sie die Vokabel selbst
    await db.delete('Vocabularies', where: 'id = ?', whereArgs: [vocabularyId]);
  }


  //**************************************************************
  //LOGIK FÜR DAS TRAINING
  //*************************************************************
  Future<List<Vocabulary>> getVocabulariesForTraining(String packName, int count) async {
    final Database db = await database;
    final int? packId = await getVocabPackIdByName(packName);

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT Vocabularies.* FROM Vocabularies '
            'JOIN VocabStammblock ON Vocabularies.id = VocabStammblock.vocabularyId '
            'WHERE VocabStammblock.vocabPackId = ? '
            'ORDER BY RANDOM() '
            'LIMIT ?',
        [packId, count]);

    return result.map((item) => Vocabulary.fromMap(item)).toList();
  }

  Future<void> startTraining(String packName, int vocabCount) async {
    final Database db = await database;
    final int? packId = await getVocabPackIdByName(packName);

    // Clear VocabTrainingBlock
    await db.delete('VocabTrainingBlock', where: 'vocabPackId = ?', whereArgs: [packId]);

    // Get vocabularies for training from VocabStammblock
    List<Vocabulary> vocabularies = await getVocabulariesForTraining(packName, vocabCount);

    // Insert selected vocabularies into VocabTrainingBlock
    for (Vocabulary vocab in vocabularies) {
      await db.insert(
        'VocabTrainingBlock',
        {
          'vocabPackId': packId,
          'vocabularyId': vocab.id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Vocabulary>> getVocabulariesForTesting(String packName, int count) async {
    final Database db = await database;
    final int? packId = await getVocabPackIdByName(packName);

    List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT Vocabularies.* FROM Vocabularies '
            'JOIN VocabStammblock ON Vocabularies.id = VocabTrainingBlock.vocabularyId '
            'WHERE VocabStammblock.vocabPackId = ? '
            'ORDER BY RANDOM() '
            'LIMIT ?',
        [packId, count]);

    return result.map((item) => Vocabulary.fromMap(item)).toList();
  }

  Future<void> updateTrainingResults(int vocabId, bool isCorrect) async {
    final Database db = await database;

    if (isCorrect) {
      await db.insert(
        'VocabGepruefterStapel',
        {
          'vocabularyId': vocabId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.insert(
        'VocabErweiterterStapel',
        {
          'vocabularyId': vocabId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<bool> isTrainingComplete(String packName) async {
    final Database db = await database;
    final int? packId = await getVocabPackIdByName(packName);

    if (packId == null) {
      // Handle the case where packId is null
      return false;
    }

    int? totalCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM VocabStammblock WHERE vocabPackId = ?',
        [packId]));

    int? testedCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(DISTINCT Vocabularies.id) FROM Vocabularies '
            'JOIN VocabTrainingBlock ON Vocabularies.id = VocabTrainingBlock.vocabularyId '
            'WHERE VocabTrainingBlock.vocabPackId = ?',
        [packId]));

    return testedCount! >= totalCount!;
  }

  Future<void> completeTraining(String packName) async {
    final Database db = await database;
    final int? packId = await getVocabPackIdByName(packName);

    await db.transaction((txn) async {
      // Move tested vocabularies to VocabGepruefterStapel
      await txn.rawInsert(
        'INSERT OR REPLACE INTO VocabGepruefterStapel (vocabularyId) '
            'SELECT DISTINCT Vocabularies.id FROM Vocabularies '
            'JOIN VocabTrainingBlock ON Vocabularies.id = VocabTrainingBlock.vocabularyId '
            'WHERE VocabTrainingBlock.vocabPackId = ?',
        [packId],
      );

      // Move remaining vocabularies to VocabErweiterterStapel
      await txn.rawInsert(
        'INSERT OR REPLACE INTO VocabErweiterterStapel (vocabularyId) '
            'SELECT id FROM Vocabularies WHERE id NOT IN ('
            '  SELECT DISTINCT Vocabularies.id FROM Vocabularies '
            '  JOIN VocabTrainingBlock ON Vocabularies.id = VocabTrainingBlock.vocabularyId '
            '  WHERE VocabTrainingBlock.vocabPackId = ?'
            ') AND id IN ('
            '  SELECT vocabularyId FROM VocabStammblock WHERE vocabPackId = ?'
            ')',
        [packId, packId],
      );

      // Clear VocabTrainingBlock
      await txn.delete('VocabTrainingBlock', where: 'vocabPackId = ?', whereArgs: [packId]);
    });
  }
}



