import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../models/food.dart';
import '../data/recipe_repository.dart';
import '../data/food_repository.dart';
import '../screens/add_food.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  static Future<Recipe?> show(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRecipePage()),
    );
  }

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final FoodRepository _foodRepo = FoodRepository();

  final TextEditingController _nameController = TextEditingController();
  final List<IngredientEntry> _ingredients = [];

  @override
  void initState() {
    super.initState();
    _ingredients.add(IngredientEntry());
  }

  void _addIngredientRow() {
    setState(() => _ingredients.add(IngredientEntry()));
  }

  void _removeIngredientRow(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  Future<void> _saveRecipe() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _toast('Recipe name is required');
      return;
    }

    final ingredients = <RecipeIngredient>[];
    for (final entry in _ingredients) {
      if (entry.food == null) continue;
      final qty = double.tryParse(entry.quantityController.text);
      if (qty == null || qty <= 0) continue;

      ingredients.add(
        RecipeIngredient(foodId: entry.food!.id, quantity: qty, unit: 'g'),
      );
    }

    if (ingredients.isEmpty) {
      _toast('Add at least one ingredient');
      return;
    }

    final recipe = Recipe(id: '', name: name, ingredients: ingredients);
    await _recipeRepo.addRecipe(recipe);

    Navigator.pop(context, recipe);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Recipe'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Recipe Name'),
                _softInput(
                  controller: _nameController,
                  hint: 'e.g. Chicken Bowl',
                ),

                const SizedBox(height: 24),

                _sectionTitle('Ingredients'),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) {
                    return IngredientCard(
                      entry: _ingredients[index],
                      foodRepo: _foodRepo,
                      onRemove: () => _removeIngredientRow(index),
                    );
                  },
                ),

                const SizedBox(height: 16),

                Center(
                  child: TextButton.icon(
                    onPressed: _addIngredientRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveRecipe,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Recipe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _softInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}

class IngredientEntry {
  Food? food;
  final TextEditingController quantityController = TextEditingController();
}

class IngredientCard extends StatelessWidget {
  final IngredientEntry entry;
  final VoidCallback onRemove;
  final FoodRepository foodRepo;

  const IngredientCard({
    super.key,
    required this.entry,
    required this.onRemove,
    required this.foodRepo,
  });

  Future<void> _selectFood(BuildContext context) async {
    final selected = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FoodPickerBottomSheet(foodRepo: foodRepo),
    );

    if (selected != null) {
      entry.food = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await _selectFood(context);
              (context as Element).markNeedsBuild();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                entry.food?.name ?? 'Select Food',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: entry.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                    suffixText: 'g',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
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
              final newFood = await AddFoodPage.show(
                context,
              ); // open AddFoodPage
              if (newFood != null) {
                await widget.foodRepo.addFood(newFood); // save to Hive

                // Reload foods from repo
                foods = await widget.foodRepo.getAllFoods();

                // Reapply filter
                final query = searchController.text.toLowerCase();
                filtered = foods
                    .where((f) => f.name.toLowerCase().contains(query))
                    .toList();

                setState(() {}); // rebuild list
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
