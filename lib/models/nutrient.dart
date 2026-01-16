import 'package:hive/hive.dart';

part 'nutrient.g.dart';

@HiveType(typeId: 1)
class Nutrient {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String unit; // g, mg, kcal, etc

  Nutrient({required this.name, required this.amount, required this.unit});
}
