import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static Database? _database;

  /// Call this first in main() if running on desktop
  static void initFfi() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  /// Get the database (singleton)
  static Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    _database = await openDatabase(path, version: 1, onCreate: _onCreate);

    // Seed data if table is empty
    await _seedFoodsIfEmpty(_database!);

    return _database!;
  }

  /// Create tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    print('✅ Tables created');
  }

  /// Seed default foods if table is empty
  static Future<void> _seedFoodsIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM foods'),
    );

    if (count == 0) {
      final defaultFoods = ['Milk', 'Eggs', 'Peanuts', 'Cheese'];
      for (var food in defaultFoods) {
        await db.insert('foods', {
          'name': food,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      print('✅ Default foods inserted');
    }
  }

  /// ---------------- CRUD METHODS ----------------

  /// Create / Insert a new food
  static Future<void> insertFood(String name) async {
    final db = await database;
    await db.insert('foods', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    print('✅ $name inserted');
  }

  /// Read / Get all foods
  static Future<List<Map<String, dynamic>>> getAllFoods() async {
    final db = await database;
    return await db.query('foods');
  }

  /// Read / Get a food by name
  static Future<Map<String, dynamic>?> getFoodByName(String name) async {
    final db = await database;
    final result = await db.query(
      'foods',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  /// Update a food name
  static Future<void> updateFood(String oldName, String newName) async {
    final db = await database;
    await db.update(
      'foods',
      {'name': newName},
      where: 'name = ?',
      whereArgs: [oldName],
    );
    print('✅ $oldName replaced with $newName');
  }

  /// Delete a food
  static Future<void> deleteFood(String name) async {
    final db = await database;
    await db.delete('foods', where: 'name = ?', whereArgs: [name]);
    print('✅ $name deleted');
  }
}
