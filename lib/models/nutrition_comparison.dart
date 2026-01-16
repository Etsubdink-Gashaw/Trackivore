import 'nutrition_goal.dart';
import 'nutrition_summary.dart';

class NutritionComparison {
  final NutritionSummary consumed;
  final NutritionSummary remaining;

  NutritionComparison({required this.consumed, required this.remaining});

  bool get isCaloriesOver => remaining.calories < 0;
  bool get isProteinOver => remaining.protein < 0;
  bool get isCarbsOver => remaining.carbs < 0;
  bool get isFatOver => remaining.fat < 0;
  bool get isFiberUnder => remaining.fiber > 0;
}
