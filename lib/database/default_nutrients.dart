import '../models/nutrient.dart';

final List<Nutrient> defaultNutrients = [
  // Energy
  Nutrient(name: 'Calories', amount: 0, unit: 'kcal'),

  // Macronutrients
  Nutrient(name: 'Carbohydrates', amount: 0, unit: 'g'),
  Nutrient(name: 'Protein', amount: 0, unit: 'g'),
  Nutrient(name: 'Fat', amount: 0, unit: 'g'),

  // Carbohydrate breakdown
  Nutrient(name: 'Fiber', amount: 0, unit: 'g'),
  Nutrient(name: 'Sugars', amount: 0, unit: 'g'),
  Nutrient(name: 'Added Sugars', amount: 0, unit: 'g'),

  // Minerals
  Nutrient(name: 'Sodium', amount: 0, unit: 'mg'),
  Nutrient(name: 'Potassium', amount: 0, unit: 'mg'),
  Nutrient(name: 'Calcium', amount: 0, unit: 'mg'),
  Nutrient(name: 'Iron', amount: 0, unit: 'mg'),
  Nutrient(name: 'Magnesium', amount: 0, unit: 'mg'),
  Nutrient(name: 'Phosphorus', amount: 0, unit: 'mg'),
  Nutrient(name: 'Zinc', amount: 0, unit: 'mg'),
  Nutrient(name: 'Copper', amount: 0, unit: 'mg'),
  Nutrient(name: 'Manganese', amount: 0, unit: 'mg'),
  Nutrient(name: 'Selenium', amount: 0, unit: 'µg'),

  // Vitamins
  Nutrient(name: 'Vitamin A', amount: 0, unit: 'µg'),
  Nutrient(name: 'Vitamin C', amount: 0, unit: 'mg'),
  Nutrient(name: 'Vitamin D', amount: 0, unit: 'µg'),
  Nutrient(name: 'Vitamin E', amount: 0, unit: 'mg'),
  Nutrient(name: 'Vitamin K', amount: 0, unit: 'µg'),

  // B Vitamins
  Nutrient(name: 'Thiamin (B1)', amount: 0, unit: 'mg'),
  Nutrient(name: 'Riboflavin (B2)', amount: 0, unit: 'mg'),
  Nutrient(name: 'Niacin (B3)', amount: 0, unit: 'mg'),
  Nutrient(name: 'Vitamin B6', amount: 0, unit: 'mg'),
  Nutrient(name: 'Folate (B9)', amount: 0, unit: 'µg'),
  Nutrient(name: 'Vitamin B12', amount: 0, unit: 'µg'),
  Nutrient(name: 'Biotin (B7)', amount: 0, unit: 'µg'),
  Nutrient(name: 'Pantothenic Acid (B5)', amount: 0, unit: 'mg'),
];
