import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/recipe_repository.dart';
import 'add_recipe.dart';

class ChooseMeal extends StatefulWidget {
  const ChooseMeal({super.key});

  static Future<Recipe?> show(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChooseMeal()),
    );
  }

  @override
  State<ChooseMeal> createState() => ChooseMealState();
}

class ChooseMealState extends State<ChooseMeal> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  List<Recipe> allRecipes = [];
  List<Recipe> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    searchController.addListener(_filterRecipes);
  }

  Future<void> _loadRecipes() async {
    await _recipeRepo.populateStarterRecipes();
    final recipes = await _recipeRepo.getAllRecipes();
    setState(() {
      allRecipes = recipes;
      filteredRecipes = recipes;
    });
  }

  void _filterRecipes() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = allRecipes
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _openAddRecipePage() async {
    final newRecipe = await AddRecipePage.show(context);
    if (newRecipe != null) {
      // Reload recipes to include newly added one
      await _loadRecipes();
      // Optional: immediately return the new recipe to the previous page
      Navigator.pop(context, newRecipe);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade600,
      appBar: AppBar(
        title: const Text('Choose Meal Item'),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            height: 700,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search meals',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.lightGreen.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.lightGreen.shade200),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredRecipes.isEmpty
                      ? const Center(child: Text('No recipes found'))
                      : ListView.builder(
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(context, recipe);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _openAddRecipePage,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Recipe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
}
