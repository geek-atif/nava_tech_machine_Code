import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/album.dart';
import '../models/photo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'nava_tech.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE albums (
        id INTEGER PRIMARY KEY,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY,
        albumId INTEGER NOT NULL,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        thumbnailUrl TEXT NOT NULL,
        FOREIGN KEY (albumId) REFERENCES albums (id)
      )
    ''');
  }

  Future<List<Album>> getAlbums() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('albums');
    return List.generate(maps.length, (i) => Album.fromJson(maps[i]));
  }

  Future<void> insertAlbums(List<Album> albums) async {
    final db = await database;
    final batch = db.batch();
    for (final album in albums) {
      batch.insert(
        'albums',
        album.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<Photo>> getPhotos(int albumId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'photos',
      where: 'albumId = ?',
      whereArgs: [albumId],
    );
    return List.generate(maps.length, (i) => Photo.fromJson(maps[i]));
  }

  Future<void> insertPhotos(List<Photo> photos) async {
    final db = await database;
    final batch = db.batch();
    for (final photo in photos) {
      batch.insert(
        'photos',
        photo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('albums');
    await db.delete('photos');
  }
}
