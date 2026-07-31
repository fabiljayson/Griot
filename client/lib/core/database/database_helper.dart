import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'african_teller.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create tables for offline caching
    await db.execute('''
      CREATE TABLE stories(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        country TEXT,
        region TEXT,
        theme TEXT,
        content TEXT,
        audio_path TEXT,
        video_path TEXT,
        image_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await db.execute('''
      CREATE TABLE user_progress(
        id INTEGER PRIMARY KEY,
        story_id INTEGER,
        user_id INTEGER,
        completed BOOLEAN DEFAULT FALSE,
        score INTEGER DEFAULT 0,
        last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (story_id) REFERENCES stories (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE achievements(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        badge_icon TEXT,
        points_required INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE user_achievements(
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        achievement_id INTEGER,
        earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (achievement_id) REFERENCES achievements (id)
      )
    ''');
  }
  
  // CRUD operations for stories
  Future<int> insertStory(Map<String, dynamic> story) async {
    final db = await database;
    return await db.insert('stories', story);
  }
  
  Future<List<Map<String, dynamic>>> getStories() async {
    final db = await database;
    return await db.query('stories');
  }
  
  Future<Map<String, dynamic>?> getStory(int id) async {
    final db = await database;
    final results = await db.query('stories', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }
  
  Future<int> updateStory(int id, Map<String, dynamic> story) async {
    final db = await database;
    return await db.update('stories', story, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> deleteStory(int id) async {
    final db = await database;
    return await db.delete('stories', where: 'id = ?', whereArgs: [id]);
  }
}