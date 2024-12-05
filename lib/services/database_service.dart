import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/news_article.dart';

// Database service to manage bookmarks.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  // Getter to retrieve or initialize the database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('news_bookmarks.db');
    return _database!;
  }

  // Initialize the database.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Callback to create the database structure.
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        title TEXT,
        description TEXT,
        url TEXT PRIMARY KEY,
        urlToImage TEXT,
        author TEXT,
        publishedAt TEXT,
        content TEXT,
        isBookmarked INTEGER
      )
    ''');
  }

  // Insert a new bookmark into the database.
  Future<void> insertBookmark(NewsArticle article) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      article.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace if the URL already exists.
    );
  }

  // Delete a bookmark from the database.
  Future<void> deleteBookmark(String url) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  // Retrieve all bookmarks from the database.
  Future<List<NewsArticle>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');

    return List.generate(maps.length, (i) {
      return NewsArticle.fromMap(maps[i]);
    });
  }
}
