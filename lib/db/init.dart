import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class DBInit {
  static Future<void> init() async {
    try {
      await DatabaseHelper.database;
      debugPrint('✅ Database initialized safely');
    } catch (e, s) {
      debugPrint('❌ Database init failed');
      debugPrint('$e');
      debugPrint('$s');
    }
  }
}
