import 'food.dart';

//import '../data/food_repository.dart';
class InventoryItem {
  final Food food;
  double quantity; // in grams (or same unit as recipe)

  InventoryItem({required this.food, required this.quantity});
}
