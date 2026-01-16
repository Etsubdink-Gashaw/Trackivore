class NutritionGoal {
  final double calories; // kcal / day
  final double protein; // g / day
  final double carbs; // g / day
  final double fat; // g / day
  final double fiber; // g / day

  const NutritionGoal({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
}

const maintenanceGoal = NutritionGoal(
  calories: 2200,
  protein: 130,
  carbs: 250,
  fat: 70,
  fiber: 30,
);
