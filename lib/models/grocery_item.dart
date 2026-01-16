import 'food.dart';

class GroceryItem {
  final Food food;
  double neededQuantity;

  GroceryItem({required this.food, required this.neededQuantity});

  // Convert to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'foodId': food.id,
      'foodName': food.name,
      'neededQuantity': neededQuantity,
    };
  }

  // Create from Map
  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      food: Food(
        id: map['foodId'],
        name: map['foodName'],
        nutrients: [], // provide empty list to satisfy required parameter
      ),
      neededQuantity: (map['neededQuantity'] as num).toDouble(),
    );
  }
}
