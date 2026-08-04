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
        blurhash TEXT,
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
    
    // Create recent searches table
    await db.execute('''
      CREATE TABLE recent_searches(
        id INTEGER PRIMARY KEY,
        query_text TEXT NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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
  
  // Recent searches operations
  Future<void> addRecentSearch(String query) async {
    final db = await database;
    
    // Check if query already exists, remove it if so
    await db.delete('recent_searches', where: 'query_text = ?', whereArgs: [query]);
    
    // Insert new search
    await db.insert('recent_searches', {
      'query_text': query,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only the 10 most recent searches
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM recent_searches');
    final total = count.first['count'] as int;
    if (total > 10) {
      await db.rawDelete('''
        DELETE FROM recent_searches 
        WHERE id NOT IN (
          SELECT id FROM recent_searches ORDER BY timestamp DESC LIMIT 10
        )
      ''');
    }
  }
  
  Future<List<String>> getRecentSearches() async {
    final db = await database;
    final results = await db.query('recent_searches', orderBy: 'timestamp DESC', limit: 10);
    return results.map((r) => r['query_text'] as String).toList();
  }
  
  Future<void> clearRecentSearches() async {
    final db = await database;
    await db.delete('recent_searches');
  }
}