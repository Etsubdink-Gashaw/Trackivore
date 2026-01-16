import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/recipe.dart';
import '../models/grocery_item.dart';
import '../models/food.dart';

import '../data/recipe_repository.dart';
import '../data/food_repository.dart';

import 'choose_meal.dart';
import 'grocery_inventory_list.dart';

class WeeklyTable extends StatefulWidget {
  const WeeklyTable({super.key});

  @override
  State<WeeklyTable> createState() => WeeklyTableState();
}

class WeeklyTableState extends State<WeeklyTable> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final FoodRepository _foodRepo = FoodRepository();

  final Box weeklyMealBox = Hive.box('weeklyMealPlan');

  final List<String> _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  final List<String> _mealTypes = ['breakfast', 'lunch', 'snack', 'dinner'];

  final Map<String, Map<String, TextEditingController>> _controllers = {};
  final Map<String, Map<String, Recipe>> _weeklyRecipes = {};

  final Map<String, double> _inventory = {};

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initWeeklyMap();
    _loadSavedPlan();
  }

  void _initControllers() {
    for (final day in _days) {
      _controllers[day] = {};
      for (final meal in _mealTypes) {
        _controllers[day]![meal] = TextEditingController();
      }
    }
  }

  void _initWeeklyMap() {
    for (final day in _days) {
      _weeklyRecipes[day] = {};
    }
  }

  @override
  void dispose() {
    for (final day in _controllers.values) {
      for (final ctrl in day.values) {
        ctrl.dispose();
      }
    }
    super.dispose();
  }

  /* -------------------- LOAD / SAVE -------------------- */

  Future<void> _loadSavedPlan() async {
    final savedPlan = weeklyMealBox.get('plan', defaultValue: {}) as Map;

    for (final day in _days) {
      if (!savedPlan.containsKey(day)) continue;

      final meals = Map<String, String>.from(savedPlan[day]);
      for (final meal in meals.entries) {
        final recipe = await _recipeRepo.getRecipe(meal.value);
        if (recipe != null) {
          _weeklyRecipes[day]![meal.key] = recipe;
          _controllers[day]![meal.key]!.text = recipe.name;
        }
      }
    }
    setState(() {});
  }

  void _saveMeal(String day, String mealType, Recipe recipe) {
    final savedPlan = weeklyMealBox.get('plan', defaultValue: {}) as Map;

    savedPlan[day] ??= {};
    savedPlan[day][mealType] = recipe.id;

    weeklyMealBox.put('plan', savedPlan);
  }

  /* -------------------- ACTIONS -------------------- */

  Future<void> _chooseMeal(String day, String mealType) async {
    final Recipe? selected = await ChooseMeal.show(context);
    if (selected == null) return;

    setState(() {
      _weeklyRecipes[day]![mealType] = selected;
      _controllers[day]![mealType]!.text = selected.name;
      _saveMeal(day, mealType, selected);
    });
  }

  Future<void> _generateWeeklyPlan() async {
    final recipes = await _recipeRepo.getAllRecipes();
    int i = 0;

    for (final day in _days) {
      for (final meal in _mealTypes) {
        if (_controllers[day]![meal]!.text.isNotEmpty) continue;
        if (i >= recipes.length) break;

        final recipe = recipes[i++];
        _weeklyRecipes[day]![meal] = recipe;
        _controllers[day]![meal]!.text = recipe.name;
        _saveMeal(day, meal, recipe);
      }
    }
    setState(() {});
  }

  /* -------------------- GROCERY LOGIC -------------------- */

  Future<List<GroceryItem>> getWeeklyGroceryItems() async {
    final Map<String, double> totalNeeded = {};
    final Map<String, Food?> foodCache = {};

    for (final day in _weeklyRecipes.values) {
      for (final recipe in day.values) {
        for (final ing in recipe.ingredients) {
          totalNeeded[ing.foodId] =
              (totalNeeded[ing.foodId] ?? 0) + ing.quantity;

          foodCache[ing.foodId] ??= await _foodRepo.getFood(ing.foodId);
        }
      }
    }

    final List<GroceryItem> result = [];
    totalNeeded.forEach((id, qty) {
      final double remaining = (qty - (_inventory[id] ?? 0)).clamp(
        0,
        double.infinity,
      );
      if (remaining > 0 && foodCache[id] != null) {
        result.add(
          GroceryItem(food: foodCache[id]!, neededQuantity: remaining),
        );
      }
    });

    return result;
  }

  void _addToInventory(List<GroceryItem> items) {
    setState(() {
      for (final item in items) {
        _inventory[item.food.id] =
            (_inventory[item.food.id] ?? 0) + item.neededQuantity;
      }
    });
  }

  Future<void> _goToGroceryInventory() async {
    final groceries = await getWeeklyGroceryItems();
    if (groceries.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroceryInventoryPage(
          initialGroceryList: groceries,
          onBought: _addToInventory,
        ),
      ),
    );
  }

  /* -------------------- UI -------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('High Protein Meal Plan'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildTable()),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(90),
          1: FixedColumnWidth(180),
          2: FixedColumnWidth(180),
          3: FixedColumnWidth(180),
          4: FixedColumnWidth(180),
        },
        children: [
          _headerRow(),
          for (final day in _days)
            _mealRow(day, 'breakfast', 'lunch', 'snack', 'dinner'),
        ],
      ),
    );
  }

  TableRow _headerRow() => const TableRow(
    children: [
      Center(child: Text('DAY')),
      Center(child: Text('BREAKFAST')),
      Center(child: Text('LUNCH')),
      Center(child: Text('SNACK')),
      Center(child: Text('DINNER')),
    ],
  );

  TableRow _mealRow(String day, String b, String l, String s, String d) {
    return TableRow(
      children: [
        Center(child: Text(day)),
        _mealCell(day, b),
        _mealCell(day, l),
        _mealCell(day, s),
        _mealCell(day, d),
      ],
    );
  }

  Widget _mealCell(String day, String meal) {
    final ctrl = _controllers[day]![meal]!;
    return GestureDetector(
      onTap: isEditMode ? () => _chooseMeal(day, meal) : null,
      child: Container(
        margin: const EdgeInsets.all(6),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            ctrl.text.isEmpty ? '—' : ctrl.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: _generateWeeklyPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Generate'),
          ),
          ElevatedButton(
            onPressed: _goToGroceryInventory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Groceries'),
          ),
          IconButton(
            color: Colors.green.shade600,
            icon: Icon(isEditMode ? Icons.check : Icons.edit),
            onPressed: () => setState(() => isEditMode = !isEditMode),
          ),
        ],
      ),
    );
  }
}
