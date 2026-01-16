import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackivore/data/recipe_repository.dart';

import '../database/default_nutrients.dart';
import '../models/user.dart';
import '../models/nutrient.dart';
import '../models/food.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../data/food_repository.dart';

class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();

    // 1. Register adapters FIRST
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(NutrientAdapter());
    Hive.registerAdapter(FoodAdapter());
    Hive.registerAdapter(RecipeIngredientAdapter());
    Hive.registerAdapter(RecipeAdapter());

    // Open all the necessary boxes
    final userBox = await Hive.openBox<User>('users');
    final nutrientBox = await Hive.openBox<Nutrient>('nutrients');

    await Hive.openBox<Food>('foods');
    await Hive.openBox<int>('food_counter');
    await Hive.openBox<Recipe>('recipes');
    await Hive.openBox<int>('recipe_counter');
    await Hive.openBox('appData');
    await Hive.openBox('weeklyMealPlan');
    await Hive.openBox('inventoryBox');
    await Hive.openBox('profileBox');
    // 3. Seed nutrients once
    if (nutrientBox.isEmpty) {
      nutrientBox.addAll(defaultNutrients);
    }

    // 4. Seed starter foods
    final foodRepo = FoodRepository();
    await foodRepo.populateStarterFoods();

    final recipeRepo = RecipeRepository();
    await recipeRepo.populateStarterRecipes();
  }
}
