import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/recipe_repository.dart';
import 'add_recipe.dart';
import 'recipe__detail.dart';

class RecipeManagementPage extends StatefulWidget {
  const RecipeManagementPage({super.key});

  @override
  State<RecipeManagementPage> createState() => _RecipeManagementPageState();
}

class _RecipeManagementPageState extends State<RecipeManagementPage> {
  final RecipeRepository _recipeRepo = RecipeRepository();

  List<Recipe> recipes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    final allRecipes = await _recipeRepo.getAllRecipes();
    if (!mounted) return;
    setState(() {
      recipes = allRecipes;
      loading = false;
    });
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    await _recipeRepo.deleteRecipe(recipe.id);
    loadRecipes();
  }

  void editRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddRecipePage()),
    ).then((_) => loadRecipes());
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Manage Recipes'),backgroundColor: Colors.green.shade600,foregroundColor: Colors.white,),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRecipePage()),
          ).then((_) => loadRecipes());
        },

        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
          ? const Center(child: Text('No recipes found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                   
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(recipe: recipe),
                        ),
                      );
                      if (result == true) {
                        loadRecipes();
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${recipe.ingredients.length} ingredients',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => editRecipe(recipe),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Recipe'),
                                content: Text('Delete "${recipe.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              deleteRecipe(recipe);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
