import 'package:flutter/material.dart';
import '../../models/nutrition_comparison.dart';

class DailyNutritionSummary extends StatelessWidget {
  final NutritionComparison comparison;

  const DailyNutritionSummary({super.key, required this.comparison});

  Widget _buildRow(String label, double consumed, double remaining) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${consumed.toStringAsFixed(0)} / ${(consumed + remaining).toStringAsFixed(0)}',
            style: TextStyle(color: remaining < 0 ? Colors.red : Colors.green),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = comparison.consumed;
    final r = comparison.remaining;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Nutrition',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildRow('Calories', c.calories, r.calories),
            _buildRow('Protein', c.protein, r.protein),
            _buildRow('Carbs', c.carbs, r.carbs),
            _buildRow('Fat', c.fat, r.fat),
            _buildRow('Fiber', c.fiber, r.fiber),
          ],
        ),
      ),
    );
  }
}
