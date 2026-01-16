import 'package:hive/hive.dart';
import 'nutrient.dart';

part 'food.g.dart';

@HiveType(typeId: 2)
class Food {
  @HiveField(0)
  String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Nutrient> nutrients;

  Food({required this.id, required this.name, required this.nutrients});
}
