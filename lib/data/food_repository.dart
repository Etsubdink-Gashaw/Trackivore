import 'package:hive/hive.dart';
import '../models/food.dart';
import 'package:trackivore/models/nutrient.dart';

class FoodRepository {
  // Get the Box for Food
  Future<Box<Food>> getBox() async {
    return await Hive.openBox<Food>('foods');
  }

  final Box<int> _counterBox = Hive.box<int>('food_counter');

  // Generate next unique ID for food
  String _getNextId() {
    final current = _counterBox.get('id', defaultValue: 0)!;
    final next = current + 1;
    _counterBox.put('id', next);
    return next.toString();
  }

  // Add new food with auto-generated ID
  Future<void> addFood(Food food) async {
    final foodBox = await getBox();
    final id = _getNextId(); // generate ID
    final newFood = Food(
      id: id,
      name: food.name,
      nutrients: food.nutrients, // keep what UI passed
    );
    await foodBox.put(newFood.id, newFood); // Add food to the box
  }

  // Get all foods from the box
  Future<List<Food>> getAllFoods() async {
    final foodBox = await getBox();
    return foodBox.values.toList();
  }

  // Get a specific food by its ID
  Future<Food?> getFood(String id) async {
    final foodBox = await getBox();
    return foodBox.get(id);
  }

  // Delete a food by its ID
  Future<void> deleteFood(String id) async {
    final foodBox = await getBox();
    await foodBox.delete(id);
  }

  // Edit an existing food
  Future<void> editFood(Food updatedFood) async {
    final foodBox = await getBox();
    final existingFood = foodBox.get(updatedFood.id);
    if (existingFood != null) {
      await foodBox.put(updatedFood.id, updatedFood);
    } else {
      print('Food with ID ${updatedFood.id} not found.');
    }
  }

  // Populate the database with starter foods if it's empty
  Future<void> populateStarterFoods() async {
    final foodBox = await getBox();
    if (foodBox.isEmpty) {
      final starterFoods = [
        Food(
          id: '1',
          name: 'Apple',
          nutrients: [
            Nutrient(name: 'Calories', amount: 52, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 14, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 2.4, unit: 'g'),
            Nutrient(name: 'Sugars', amount: 10.4, unit: 'g'),
            Nutrient(name: 'Protein', amount: 0.3, unit: 'g'),
            Nutrient(name: 'Fat', amount: 0.2, unit: 'g'),
            Nutrient(name: 'Vitamin C', amount: 4.6, unit: 'mg'),
            Nutrient(name: 'Potassium', amount: 107, unit: 'mg'),
          ],
        ),

        Food(
          id: '2',
          name: 'Banana',
          nutrients: [
            Nutrient(name: 'Calories', amount: 89, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 23, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 2.6, unit: 'g'),
            Nutrient(name: 'Sugars', amount: 12.2, unit: 'g'),
            Nutrient(name: 'Protein', amount: 1.1, unit: 'g'),
            Nutrient(name: 'Fat', amount: 0.3, unit: 'g'),
            Nutrient(name: 'Vitamin B6', amount: 0.4, unit: 'mg'),
            Nutrient(name: 'Potassium', amount: 358, unit: 'mg'),
          ],
        ),

        Food(
          id: '3',
          name: 'Egg',
          nutrients: [
            Nutrient(name: 'Calories', amount: 155, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 13, unit: 'g'),
            Nutrient(name: 'Fat', amount: 11, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 1.1, unit: 'g'),
            Nutrient(name: 'Vitamin B12', amount: 1.1, unit: 'µg'),
            Nutrient(name: 'Vitamin D', amount: 2.2, unit: 'µg'),
            Nutrient(name: 'Iron', amount: 1.8, unit: 'mg'),
          ],
        ),

        Food(
          id: '4',
          name: 'Bread',
          nutrients: [
            Nutrient(name: 'Calories', amount: 265, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 49, unit: 'g'),
            Nutrient(name: 'Protein', amount: 9, unit: 'g'),
            Nutrient(name: 'Fat', amount: 3.2, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 2.7, unit: 'g'),
            Nutrient(name: 'Sodium', amount: 491, unit: 'mg'),
            Nutrient(name: 'Iron', amount: 3.6, unit: 'mg'),
          ],
        ),

        Food(
          id: '5',
          name: 'Chicken Breast',
          nutrients: [
            Nutrient(name: 'Calories', amount: 165, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 31, unit: 'g'),
            Nutrient(name: 'Fat', amount: 3.6, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 0, unit: 'g'),
            Nutrient(name: 'Vitamin B6', amount: 0.6, unit: 'mg'),
            Nutrient(name: 'Niacin (B3)', amount: 13.7, unit: 'mg'),
            Nutrient(name: 'Phosphorus', amount: 210, unit: 'mg'),
          ],
        ),

        Food(
          id: '6',
          name: 'Rice',
          nutrients: [
            Nutrient(name: 'Calories', amount: 130, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 28, unit: 'g'),
            Nutrient(name: 'Protein', amount: 2.7, unit: 'g'),
            Nutrient(name: 'Fat', amount: 0.3, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 0.4, unit: 'g'),
            Nutrient(name: 'Magnesium', amount: 12, unit: 'mg'),
          ],
        ),

        Food(
          id: '7',
          name: 'Salmon',
          nutrients: [
            Nutrient(name: 'Calories', amount: 208, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 20, unit: 'g'),
            Nutrient(name: 'Fat', amount: 13, unit: 'g'),
            Nutrient(name: 'Saturated Fat', amount: 3.1, unit: 'g'),
            Nutrient(name: 'Vitamin D', amount: 10.9, unit: 'µg'),
            Nutrient(name: 'Vitamin B12', amount: 3.2, unit: 'µg'),
            Nutrient(name: 'Selenium', amount: 36.5, unit: 'µg'),
          ],
        ),

        Food(
          id: '8',
          name: 'Oats',
          nutrients: [
            Nutrient(name: 'Calories', amount: 389, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 66, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 10.6, unit: 'g'),
            Nutrient(name: 'Protein', amount: 17, unit: 'g'),
            Nutrient(name: 'Fat', amount: 7, unit: 'g'),
            Nutrient(name: 'Iron', amount: 4.7, unit: 'mg'),
            Nutrient(name: 'Magnesium', amount: 177, unit: 'mg'),
          ],
        ),

        Food(
          id: '9',
          name: 'Protein Powder',
          nutrients: [
            Nutrient(name: 'Calories', amount: 400, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 80, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 10, unit: 'g'),
            Nutrient(name: 'Fat', amount: 6, unit: 'g'),
            Nutrient(name: 'Calcium', amount: 500, unit: 'mg'),
          ],
        ),

        Food(
          id: '10',
          name: 'Beef',
          nutrients: [
            Nutrient(name: 'Calories', amount: 250, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 26, unit: 'g'),
            Nutrient(name: 'Fat', amount: 20, unit: 'g'),
            Nutrient(name: 'Iron', amount: 2.6, unit: 'mg'),
            Nutrient(name: 'Zinc', amount: 4.8, unit: 'mg'),
            Nutrient(name: 'Vitamin B12', amount: 2.6, unit: 'µg'),
          ],
        ),

        Food(
          id: '11',
          name: 'Mixed Nuts',
          nutrients: [
            Nutrient(name: 'Calories', amount: 560, unit: 'kcal'),
            Nutrient(name: 'Fat', amount: 49, unit: 'g'),
            Nutrient(name: 'Protein', amount: 20, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 22, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 8, unit: 'g'),
            Nutrient(name: 'Magnesium', amount: 160, unit: 'mg'),
          ],
        ),

        Food(
          id: '12',
          name: 'Greek Yogurt',
          nutrients: [
            Nutrient(name: 'Calories', amount: 59, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 10, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 3.6, unit: 'g'),
            Nutrient(name: 'Fat', amount: 0.4, unit: 'g'),
            Nutrient(name: 'Calcium', amount: 110, unit: 'mg'),
            Nutrient(name: 'Vitamin B12', amount: 0.8, unit: 'µg'),
          ],
        ),

        Food(
          id: '13',
          name: 'Tuna',
          nutrients: [
            Nutrient(name: 'Calories', amount: 132, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 28, unit: 'g'),
            Nutrient(name: 'Fat', amount: 1.3, unit: 'g'),
            Nutrient(name: 'Vitamin B12', amount: 2.5, unit: 'µg'),
            Nutrient(name: 'Selenium', amount: 80, unit: 'µg'),
          ],
        ),

        Food(
          id: '14',
          name: 'Avocado',
          nutrients: [
            Nutrient(name: 'Calories', amount: 160, unit: 'kcal'),
            Nutrient(name: 'Fat', amount: 15, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 9, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 7, unit: 'g'),
            Nutrient(name: 'Potassium', amount: 485, unit: 'mg'),
          ],
        ),

        Food(
          id: '15',
          name: 'Turkey',
          nutrients: [
            Nutrient(name: 'Calories', amount: 135, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 29, unit: 'g'),
            Nutrient(name: 'Fat', amount: 1.6, unit: 'g'),
            Nutrient(name: 'Vitamin B6', amount: 0.8, unit: 'mg'),
            Nutrient(name: 'Niacin (B3)', amount: 10.8, unit: 'mg'),
          ],
        ),

        Food(
          id: '16',
          name: 'Vegetables (Mixed)',
          nutrients: [
            Nutrient(name: 'Calories', amount: 40, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 8, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 3, unit: 'g'),
            Nutrient(name: 'Vitamin C', amount: 20, unit: 'mg'),
          ],
        ),

        Food(
          id: '17',
          name: 'Quinoa',
          nutrients: [
            Nutrient(name: 'Calories', amount: 120, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 21, unit: 'g'),
            Nutrient(name: 'Protein', amount: 4.4, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 2.8, unit: 'g'),
            Nutrient(name: 'Magnesium', amount: 64, unit: 'mg'),
          ],
        ),

        Food(
          id: '18',
          name: 'Hummus',
          nutrients: [
            Nutrient(name: 'Calories', amount: 166, unit: 'kcal'),
            Nutrient(name: 'Fat', amount: 9.6, unit: 'g'),
            Nutrient(name: 'Protein', amount: 7.9, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 14, unit: 'g'),
            Nutrient(name: 'Fiber', amount: 6, unit: 'g'),
          ],
        ),

        Food(
          id: '19',
          name: 'Shrimp',
          nutrients: [
            Nutrient(name: 'Calories', amount: 99, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 24, unit: 'g'),
            Nutrient(name: 'Fat', amount: 0.3, unit: 'g'),
            Nutrient(name: 'Selenium', amount: 48, unit: 'µg'),
          ],
        ),

        Food(
          id: '20',
          name: 'Pasta',
          nutrients: [
            Nutrient(name: 'Calories', amount: 131, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 25, unit: 'g'),
            Nutrient(name: 'Protein', amount: 5, unit: 'g'),
            Nutrient(name: 'Fat', amount: 1.1, unit: 'g'),
          ],
        ),

        Food(
          id: '21',
          name: 'Pancakes',
          nutrients: [
            Nutrient(name: 'Calories', amount: 227, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 28, unit: 'g'),
            Nutrient(name: 'Protein', amount: 6, unit: 'g'),
            Nutrient(name: 'Fat', amount: 9, unit: 'g'),
          ],
        ),

        Food(
          id: '22',
          name: 'Granola Bar',
          nutrients: [
            Nutrient(name: 'Calories', amount: 471, unit: 'kcal'),
            Nutrient(name: 'Carbohydrates', amount: 64, unit: 'g'),
            Nutrient(name: 'Protein', amount: 10, unit: 'g'),
            Nutrient(name: 'Fat', amount: 20, unit: 'g'),
          ],
        ),

        Food(
          id: '23',
          name: 'Pork Chop',
          nutrients: [
            Nutrient(name: 'Calories', amount: 231, unit: 'kcal'),
            Nutrient(name: 'Protein', amount: 25, unit: 'g'),
            Nutrient(name: 'Fat', amount: 13, unit: 'g'),
            Nutrient(name: 'Vitamin B12', amount: 0.7, unit: 'µg'),
            Nutrient(name: 'Zinc', amount: 2.4, unit: 'mg'),
          ],
        ),

        Food(
          id: '24',
          name: 'Cream Cheese',
          nutrients: [
            Nutrient(name: 'Calories', amount: 342, unit: 'kcal'),
            Nutrient(name: 'Fat', amount: 34, unit: 'g'),
            Nutrient(name: 'Protein', amount: 6, unit: 'g'),
            Nutrient(name: 'Carbohydrates', amount: 4, unit: 'g'),
            Nutrient(name: 'Calcium', amount: 97, unit: 'mg'),
          ],
        ),
      ];

      // Add starter foods to the box
      for (var food in starterFoods) {
        await addFood(food); // Using the existing addFood function
      }
    }
  }
}
