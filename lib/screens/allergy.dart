import 'package:flutter/material.dart';
import '../db/food_dao.dart';
import '../db/food_model.dart';

class AllergySheet extends StatelessWidget {
  const AllergySheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Food>>(
      future: FoodDao.getAllFoods(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        final foods = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: foods.map((food) {
            return ListTile(
              title: Text(food.name),
              onTap: () {
                Navigator.pop(context, food.name);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
