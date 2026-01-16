import 'package:hive/hive.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';

class RecipeRepository {
  // Get the Box for Recipe
  Future<Box<Recipe>> getBox() async {
    return await Hive.openBox<Recipe>('recipes');
  }

  final Box<int> _counterBox = Hive.box<int>('recipe_counter');

  // Generate next unique ID for recipe
  String _getNextId() {
    final current = _counterBox.get('id', defaultValue: 0)!;
    final next = current + 1;
    _counterBox.put('id', next);
    return next.toString();
  }

  // Add new recipe with auto-generated ID
  Future<void> addRecipe(Recipe recipe) async {
    final recipeBox = await getBox();
    final id = _getNextId();

    final newRecipe = Recipe(
      id: id,
      name: recipe.name,
      //servings: recipe.servings,
      ingredients: recipe.ingredients,
    );

    await recipeBox.put(newRecipe.id, newRecipe);
  }

  // Update an existing recipe (ID unchanged)
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final recipeBox = await getBox();
    if (recipeBox.containsKey(updatedRecipe.id)) {
      await recipeBox.put(updatedRecipe.id, updatedRecipe);
    }
  }

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    final recipeBox = await getBox();
    return recipeBox.values.toList();
  }

  // Get recipe by ID
  Future<Recipe?> getRecipe(String id) async {
    final recipeBox = await getBox();
    return recipeBox.get(id);
  }

  // Delete recipe
  Future<void> deleteRecipe(String id) async {
    final recipeBox = await getBox();
    await recipeBox.delete(id);
  }

  // Populate starter recipes if empty
  Future<void> populateStarterRecipes() async {
    final recipeBox = await getBox();
    if (recipeBox.isNotEmpty) return;

    final starterRecipes = [
      Recipe(
        id: 'r1',
        name: 'Apple Banana Salad',
        ingredients: [
          RecipeIngredient(foodId: '1', quantity: 150, unit: 'g'),
          RecipeIngredient(foodId: '2', quantity: 120, unit: 'g'),
        ],
      ),

      // MON
      Recipe(
        id: 'r2',
        name: 'Egg Toast',
        ingredients: [
          RecipeIngredient(foodId: '3', quantity: 120, unit: 'g'),
          RecipeIngredient(foodId: '4', quantity: 80, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r3',
        name: 'Chicken Bowl',
        ingredients: [
          RecipeIngredient(foodId: '5', quantity: 180, unit: 'g'),
          RecipeIngredient(foodId: '6', quantity: 150, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r4',
        name: 'Protein Shake',
        ingredients: [
          RecipeIngredient(foodId: '9', quantity: 40, unit: 'g'),
          RecipeIngredient(foodId: '12', quantity: 200, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r5',
        name: 'Salmon Rice',
        ingredients: [
          RecipeIngredient(foodId: '7', quantity: 170, unit: 'g'),
          RecipeIngredient(foodId: '6', quantity: 150, unit: 'g'),
        ],
      ),

      // TUE
      Recipe(
        id: 'r6',
        name: 'Protein Oats',
        ingredients: [
          RecipeIngredient(foodId: '8', quantity: 80, unit: 'g'),
          RecipeIngredient(foodId: '9', quantity: 30, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r7',
        name: 'Beef Stir Fry',
        ingredients: [
          RecipeIngredient(foodId: '10', quantity: 180, unit: 'g'),
          RecipeIngredient(foodId: '16', quantity: 150, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r8',
        name: 'Mixed Nuts Snack',
        ingredients: [RecipeIngredient(foodId: '11', quantity: 45, unit: 'g')],
      ),
      Recipe(
        id: 'r9',
        name: 'Chicken Wrap',
        ingredients: [
          RecipeIngredient(foodId: '5', quantity: 160, unit: 'g'),
          RecipeIngredient(foodId: '4', quantity: 90, unit: 'g'),
        ],
      ),

      // WED
      Recipe(
        id: 'r10',
        name: 'Greek Yogurt',
        ingredients: [RecipeIngredient(foodId: '12', quantity: 300, unit: 'g')],
      ),
      Recipe(
        id: 'r11',
        name: 'Tuna Salad',
        ingredients: [
          RecipeIngredient(foodId: '13', quantity: 160, unit: 'g'),
          RecipeIngredient(foodId: '16', quantity: 120, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r12',
        name: 'Fruit Salad',
        ingredients: [
          RecipeIngredient(foodId: '1', quantity: 100, unit: 'g'),
          RecipeIngredient(foodId: '2', quantity: 100, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r13',
        name: 'Egg Fried Rice',
        ingredients: [
          RecipeIngredient(foodId: '3', quantity: 120, unit: 'g'),
          RecipeIngredient(foodId: '6', quantity: 180, unit: 'g'),
        ],
      ),

      // THU
      Recipe(
        id: 'r14',
        name: 'Avocado Toast',
        ingredients: [
          RecipeIngredient(foodId: '14', quantity: 100, unit: 'g'),
          RecipeIngredient(foodId: '4', quantity: 80, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r15',
        name: 'Turkey Sandwich',
        ingredients: [
          RecipeIngredient(foodId: '15', quantity: 160, unit: 'g'),
          RecipeIngredient(foodId: '4', quantity: 100, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r16',
        name: 'Veggie Sticks',
        ingredients: [RecipeIngredient(foodId: '16', quantity: 200, unit: 'g')],
      ),
      Recipe(
        id: 'r17',
        name: 'Beef Tacos',
        ingredients: [
          RecipeIngredient(foodId: '10', quantity: 180, unit: 'g'),
          RecipeIngredient(foodId: '4', quantity: 70, unit: 'g'),
        ],
      ),

      // FRI
      Recipe(
        id: 'r18',
        name: 'Smoothie Bowl',
        ingredients: [
          RecipeIngredient(foodId: '2', quantity: 150, unit: 'g'),
          RecipeIngredient(foodId: '12', quantity: 200, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r19',
        name: 'Quinoa Salad',
        ingredients: [
          RecipeIngredient(foodId: '17', quantity: 180, unit: 'g'),
          RecipeIngredient(foodId: '16', quantity: 120, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r20',
        name: 'Hummus & Veggies',
        ingredients: [
          RecipeIngredient(foodId: '18', quantity: 80, unit: 'g'),
          RecipeIngredient(foodId: '16', quantity: 150, unit: 'g'),
        ],
      ),
      Recipe(
        id: 'r21',
        name: 'Grilled Chicken',
        ingredients: [RecipeIngredient(foodId: '5', quantity: 220, unit: 'g')],
      ),
    ];

    for (final recipe in starterRecipes) {
      await addRecipe(recipe);
    }
  }
}
