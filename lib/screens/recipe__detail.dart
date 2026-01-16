import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/food.dart';
import '../models/nutrition_summary.dart';
import '../data/recipe_repository.dart';
import '../data/food_repository.dart';
import '../services/recipe_nutrition_calculator.dart';
import 'add_food.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final FoodRepository _foodRepo = FoodRepository();

  late TextEditingController _nameController;
  List<IngredientEntry> _ingredients = [];
  Map<String, Food> _foodMap = {};
  NutritionSummary? _nutritionSummary;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe.name);
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var entry in _ingredients) {
      entry.quantityController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load all foods
    final foods = await _foodRepo.getAllFoods();
    _foodMap = {for (var food in foods) food.id: food};

    // Load ingredients
    _ingredients = widget.recipe.ingredients.map((ingredient) {
      final entry = IngredientEntry();
      entry.foodId = ingredient.foodId;
      entry.food = _foodMap[ingredient.foodId];
      entry.quantityController.text = ingredient.quantity.toString();
      entry.unit = ingredient.unit;
      return entry;
    }).toList();

    _calculateNutrition();

    setState(() => _isLoading = false);
  }

  void _calculateNutrition() {
    if (_foodMap.isEmpty) return;

    // Create a temporary recipe with current ingredients
    final tempIngredients = _ingredients
        .where((e) => e.food != null && e.quantityController.text.isNotEmpty)
        .map((e) {
          final qty = double.tryParse(e.quantityController.text) ?? 0;
          return RecipeIngredient(
            foodId: e.food!.id,
            quantity: qty,
            unit: e.unit,
          );
        })
        .toList();

    final tempRecipe = Recipe(
      id: widget.recipe.id,
      name: _nameController.text,
      ingredients: tempIngredients,
    );

    _nutritionSummary = RecipeNutritionCalculator.calculate(
      tempRecipe,
      _foodMap,
    );
    setState(() {});
  }

  Future<void> _saveRecipe() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe name is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ingredients = <RecipeIngredient>[];
    for (final entry in _ingredients) {
      if (entry.food == null) continue;
      final qty = double.tryParse(entry.quantityController.text);
      if (qty == null || qty <= 0) continue;

      ingredients.add(
        RecipeIngredient(
          foodId: entry.food!.id,
          quantity: qty,
          unit: entry.unit,
        ),
      );
    }

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one ingredient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        name: name,
        ingredients: ingredients,
      );

      await _recipeRepo.updateRecipe(updatedRecipe);

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe updated successfully!'),
          backgroundColor: Color(0xFF43A047),
          duration: Duration(seconds: 2),
        ),
      );

      // Notify parent to refresh
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add(IngredientEntry());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].quantityController.dispose();
      _ingredients.removeAt(index);
      _calculateNutrition();
    });
  }

  Future<void> _selectFood(IngredientEntry entry) async {
    final selected = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FoodPickerBottomSheet(foodRepo: _foodRepo),
    );

    if (selected != null) {
      setState(() {
        entry.food = selected;
        entry.foodId = selected.id;
        _calculateNutrition();
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values
        _nameController.text = widget.recipe.name;
        _loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.lightGreen.shade50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Recipe Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.lightGreen.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Recipe Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.black87,
            ),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Cancel' : 'Edit Recipe',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _recipeNameCard(),
            const SizedBox(height: 16),
            _ingredientsCard(),
            const SizedBox(height: 16),
            _nutritionCard(),
            if (_isEditing) ...[const SizedBox(height: 24), _saveButton()],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _recipeNameCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Recipe Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditing
              ? TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Enter recipe name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green.shade600,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                )
              : Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _ingredientsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isEditing)
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_ingredients.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No ingredients',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final ingredient = entry.value;
              return _ingredientItem(ingredient, index);
            }),
        ],
      ),
    );
  }

  Widget _ingredientItem(IngredientEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _selectFood(entry),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.food?.name ?? 'Select Food',
                                  style: TextStyle(
                                    color: entry.food == null
                                        ? Colors.grey.shade600
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Quantity',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (_) => _calculateNutrition(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              entry.unit,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.food?.name ?? 'Unknown Food',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.quantityController.text} ${entry.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeIngredient(index),
            ),
        ],
      ),
    );
  }

  Widget _nutritionCard() {
    if (_nutritionSummary == null) {
      return const SizedBox.shrink();
    }

    final summary = _nutritionSummary!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Nutrition Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _nutritionRow(
            'Calories',
            '${summary.calories.toStringAsFixed(1)}',
            'kcal',
            Colors.orange,
          ),
          _nutritionRow(
            'Protein',
            '${summary.protein.toStringAsFixed(1)}',
            'g',
            Colors.blue,
          ),
          _nutritionRow(
            'Carbohydrates',
            '${summary.carbs.toStringAsFixed(1)}',
            'g',
            Colors.purple,
          ),
          _nutritionRow(
            'Fat',
            '${summary.fat.toStringAsFixed(1)}',
            'g',
            Colors.red,
          ),
          _nutritionRow(
            'Fiber',
            '${summary.fiber.toStringAsFixed(1)}',
            'g',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveRecipe,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF43A047),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.lightGreen.shade100, width: 1.5),
    );
  }
}

class IngredientEntry {
  String? foodId;
  Food? food;
  final TextEditingController quantityController = TextEditingController();
  String unit = 'g';
}

class FoodPickerBottomSheet extends StatefulWidget {
  final FoodRepository foodRepo;

  const FoodPickerBottomSheet({super.key, required this.foodRepo});

  @override
  State<FoodPickerBottomSheet> createState() => _FoodPickerBottomSheetState();
}

class _FoodPickerBottomSheetState extends State<FoodPickerBottomSheet> {
  List<Food> foods = [];
  List<Food> filtered = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    searchController.addListener(_filter);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await widget.foodRepo.populateStarterFoods();
    foods = await widget.foodRepo.getAllFoods();
    setState(() => filtered = foods);
  }

  void _filter() {
    final q = searchController.text.toLowerCase();
    setState(() {
      filtered = foods.where((f) => f.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 520,
      child: Column(
        children: [
          Container(
            height: 5,
            width: 50,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search food',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final food = filtered[i];
                return ListTile(
                  title: Text(food.name),
                  onTap: () => Navigator.pop(context, food),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final newFood = await AddFoodPage.show(context);
              if (newFood != null) {
                await widget.foodRepo.addFood(newFood);
                foods = await widget.foodRepo.getAllFoods();
                final query = searchController.text.toLowerCase();
                filtered = foods
                    .where((f) => f.name.toLowerCase().contains(query))
                    .toList();
                setState(() {});
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Food'),
          ),
        ],
      ),
    );
  }
}
