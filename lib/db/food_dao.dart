import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'food_model.dart';

class FoodDao {
  static Future<List<Food>> getAllFoods() async {
    final db = await DatabaseHelper.database;
    final result = await db.query('foods');
    return result.map((e) => Food.fromMap(e)).toList();
  }

  static Future<void> addFood(String name) async {
    final db = await DatabaseHelper.database;
    await db.insert('foods', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
}
