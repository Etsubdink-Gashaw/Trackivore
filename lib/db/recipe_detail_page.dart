import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/recipe.dart';
import '../models/food.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Recipe? recipe;
  Map<String, Food> foodMap = {};
  Map<String, double> nutrients = {};
  List<String> warnings = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final recipeBox = await Hive.openBox<Recipe>('recipes');
    final foodBox = await Hive.openBox<Food>('foods');

    if (recipeBox.isEmpty) {
      setState(() {
        warnings.add('No recipes in Hive');
      });
      return;
    }

    final r = recipeBox.values.first; // Pick first recipe for testing

    foodMap = {for (final food in foodBox.values) food.id: food};

    final totals = <String, double>{};
    final localWarnings = <String>[];

    for (final ingredient in r.ingredients) {
      final food = foodMap[ingredient.foodId];

      if (food == null) {
        localWarnings.add(
          'Missing food for ingredient id: ${ingredient.foodId}',
        );
        continue;
      }

      if (ingredient.unit != 'g') {
        localWarnings.add(
          'Unsupported unit "${ingredient.unit}" for ${food.name}',
        );
        continue;
      }

      for (final nutrient in food.nutrients) {
        final value = nutrient.amount * (ingredient.quantity / 100);
        totals[nutrient.name] = (totals[nutrient.name] ?? 0) + value;
      }
    }

    if (!mounted) return;

    setState(() {
      recipe = r;
      nutrients = totals;
      warnings = localWarnings;
    });
  }

  String getUnit(String name) {
    switch (name.toLowerCase()) {
      case 'calories':
        return 'kcal';
      case 'protein':
      case 'fat':
      case 'carbohydrates':
        return 'g';
      case 'potassium':
        return 'mg';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: recipe == null && warnings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (recipe != null) ...[
                    Text(
                      recipe!.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Ingredients:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...recipe!.ingredients.map((i) {
                      final food = foodMap[i.foodId];
                      final name = food?.name ?? 'UNKNOWN FOOD (${i.foodId})';
                      return Text('- $name — ${i.quantity} ${i.unit}');
                    }),
                    const SizedBox(height: 16),
                  ],

                  if (warnings.isNotEmpty) ...[
                    const Text(
                      'Warnings:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    ...warnings.map(
                      (w) => Text(
                        '• $w',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    'Total Nutrients:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (nutrients.isEmpty) const Text('No nutrients calculated'),
                  ...nutrients.entries.map(
                    (e) => ListTile(
                      title: Text(e.key),
                      trailing: Text(
                        '${e.value.toStringAsFixed(2)} ${getUnit(e.key)}',
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
