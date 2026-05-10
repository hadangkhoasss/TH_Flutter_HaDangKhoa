import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, fileName);
    return await openDatabase(
      path,
      version: 2,  
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE notes ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE notes ADD COLUMN priority INTEGER NOT NULL DEFAULT 1");
    }
  }

  Future<int> create(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> readAll() async {
    final db = await database;
    final maps = await db.query(
      'notes',
      orderBy: 'isPinned DESC, priority DESC, updatedAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<int> update(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
