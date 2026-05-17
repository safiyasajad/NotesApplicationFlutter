//Database Helper class
import 'package:notesapp/model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;


//database helper class 

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final dbFullPath = path.join(dbPath, filePath);

    return await openDatabase(dbFullPath, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        createdAt $textType
      )
    ''');
  }




  // CREATE - Insert a note
  Future<Note> createNote(Note note) async {
    final db = await database;
    final id = await db.insert('notes', note.toMap()); //toMap() method converts JSON to object before insierting it 
    return note.copyWith(id: id);
  }

  // READ - Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await database; 
    const orderBy = 'createdAt DESC';
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // READ - Get a single note by ID
  Future<Note?> getNoteById(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // UPDATE - Update a note
  Future<int> updateNote(Note note) async {
    final db = await database; //get database instance
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // DELETE - Delete a note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}