import 'package:hive/hive.dart';
import '../models/user.dart';

class UserRepository {
  // 👇 THIS is "getting the box"
  final Box<User> _userBox = Hive.box<User>('users');

  Future<void> addUser(User user) async {
    await _userBox.put(user.id, user);
  }

  User? getUser(String id) {
    return _userBox.get(id);
  }

  List<User> getAllUsers() {
    return _userBox.values.toList();
  }

  Future<void> deleteUser(String id) async {
    await _userBox.delete(id);
  }
}
