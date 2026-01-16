class NutritionSummary {
  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;
  double fiber = 0;

  void add(NutritionSummary other) {
    calories += other.calories;
    protein += other.protein;
    carbs += other.carbs;
    fat += other.fat;
    fiber += other.fiber;
  }
}
