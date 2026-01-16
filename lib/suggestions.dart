import 'package:flutter/material.dart';
import 'package:trackivore/models/food.dart';
import 'package:trackivore/models/recipe.dart';
import 'data/food_repository.dart';
import 'data/recipe_repository.dart';
import '../models/nutrient.dart';
import 'models/recipe_ingredient.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({super.key});

  @override
  State<Suggestions> createState() => SuggestionsState();
}

class SuggestionsState extends State<Suggestions> {
  final foodRepo = FoodRepository();

  final nameController = TextEditingController();
  final nutrientAmountController = TextEditingController();
  final List<Nutrient> tempNutrients = [];

  Nutrient? selectedNutrient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hive CRUD Example')),

      body: Column(
        children: [
          // Food Name Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Food name',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Nutrient Inputs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Dropdown to select nutrient
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<Nutrient>(
                      'nutrients',
                    ).listenable(),
                    builder: (context, Box<Nutrient> box, _) {
                      if (box.isEmpty) return Text('No nutrients available');
                      return DropdownButton<Nutrient>(
                        value: selectedNutrient,
                        hint: Text('Select Nutrient'),
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            selectedNutrient = value;
                          });
                        },
                        items: box.values.map((n) {
                          return DropdownMenuItem(
                            value: n,
                            child: Text(n.name),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                SizedBox(width: 8),

                // Amount input with unit displayed
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nutrientAmountController,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            hintText: selectedNutrient?.unit ?? '',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      if (selectedNutrient != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(selectedNutrient!.unit),
                        ),
                    ],
                  ),
                ),

                SizedBox(width: 8),

                // Add nutrient button
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final amount = double.tryParse(
                      nutrientAmountController.text.trim(),
                    );
                    if (selectedNutrient == null || amount == null) return;
                    setState(() {
                      tempNutrients.add(
                        Nutrient(
                          name: selectedNutrient!.name,
                          amount: amount,
                          unit: selectedNutrient!.unit,
                        ),
                      );
                    });
                    nutrientAmountController.clear();
                  },
                ),
              ],
            ),
          ),

          // Show added nutrients
          if (tempNutrients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tempNutrients.map((n) {
                  return Chip(
                    label: Text('${n.name}: ${n.amount} ${n.unit}'),
                    onDeleted: () {
                      setState(() {
                        tempNutrients.remove(n);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

          // Add Food Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                final foodName = nameController.text.trim();
                if (foodName.isEmpty) return;
                foodRepo.addFood(
                  Food(
                    id: '',
                    name: foodName,
                    nutrients: List.from(tempNutrients),
                  ),
                );
                setState(() {
                  tempNutrients.clear(); // clear chips
                  nameController.clear();
                });
              },
              child: Text('Add Food'),
            ),
          ),

          // List of Foods
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Food>('foods').listenable(),
              builder: (context, Box<Food> box, _) {
                if (box.isEmpty) return Center(child: Text('No foods'));
                final foods = box.values.toList();
                return ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return ExpansionTile(
                      title: Text(food.name),
                      subtitle: Text(food.id),
                      children: [
                        ...food.nutrients.asMap().entries.map((entry) {
                          final index = entry.key;
                          final n = entry.value;
                          final controller = TextEditingController(
                            text: n.amount.toString(),
                          );

                          return ListTile(
                            title: Text(n.name),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        suffixText: n.unit,
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      onSubmitted: (value) {
                                        final newAmount = double.tryParse(
                                          value,
                                        );
                                        if (newAmount != null) {
                                          setState(() {
                                            food.nutrients[index] = Nutrient(
                                              name: n.name,
                                              amount: newAmount,
                                              unit: n.unit,
                                            );
                                            foodRepo.addFood(
                                              food,
                                            ); // update Hive
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        food.nutrients.removeAt(index);
                                        foodRepo.addFood(food); // update Hive
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        ListTile(
                          title: const Text('Delete Food'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              foodRepo.deleteFood(food.id);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
