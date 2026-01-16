import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'recipe_page.dart';
import '../screens/add_food.dart';
import '../screens/add_recipe.dart';

import 'grocery_inventory_list.dart';
import 'profile_page.dart';
import 'weekly_table.dart';

import '../models/grocery_item.dart';
import '../data/food_repository.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.name,
    this.ageGroup,
    this.allergies,
    this.diets,
  });

  /// Optional so Hive can be the fallback source
  final String? name;
  final String? ageGroup;
  final Set<String>? allergies;
  final Set<String>? diets;

  @override
  State<HomePage> createState() => _HomePageState();

  /* -------------------- HIVE HELPERS -------------------- */

  static Future<List<GroceryItem>> loadGroceryItemsFromHive(
    String key,
    FoodRepository foodRepo,
  ) async {
    final box = Hive.box('inventoryBox');
    final rawList = box.get(key, defaultValue: []) as List;

    final List<GroceryItem> items = [];

    for (final map in rawList) {
      final foodId = map['foodId'] as String;
      final qty = map['quantity'] as double;

      final food = await foodRepo.getFood(foodId);
      if (food != null) {
        items.add(GroceryItem(food: food, neededQuantity: qty));
      }
    }

    return items;
  }
}

class _HomePageState extends State<HomePage> {
  static const String currentRoute = 'home';

  late final String name;
  late final String ageGroup;
  late final Set<String> allergies;
  late final Set<String> diets;

  void _goToAddMeal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRecipePage()),
    );
  }

  void _goToAddFood() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddFoodPage(),
      ), // Make sure AddMeal class exists
    );
  }

  @override
  void initState() {
    super.initState();

    final box = Hive.box('profileBox');

    name = widget.name ?? box.get('name', defaultValue: '');
    ageGroup = widget.ageGroup ?? box.get('ageGroup', defaultValue: '');

    allergies =
        widget.allergies ??
        (box.get('allergies', defaultValue: []) as List).cast<String>().toSet();

    diets =
        widget.diets ??
        (box.get('diets', defaultValue: []) as List).cast<String>().toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,

      /* -------------------- APP BAR -------------------- */
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Trackivore',
          style: TextStyle(
            color: Colors.green.shade900,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.person),
              color: Colors.green.shade900,
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      name: name,
                      ageGroup: ageGroup,
                      allergies: allergies,
                      diets: diets,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      /* -------------------- DRAWER -------------------- */
      drawer: Drawer(
        backgroundColor: Colors.lightGreen.shade50,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green.shade100),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,

                        child: IconButton(
                          icon: const Icon(Icons.person),
                          color: Colors.green.shade900,
                          tooltip: 'Profile',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfilePage(
                                  name: name,
                                  ageGroup: ageGroup,
                                  allergies: allergies,
                                  diets: diets,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            _drawerItem(
              context,
              label: 'Home',
              icon: Icons.dashboard,
              isSelected: currentRoute == 'home',
              onTap: () => Navigator.pop(context),
            ),

            _drawerItem(
              context,
              label: 'Weekly Meal Plan',
              icon: Icons.calendar_month,
              isSelected: currentRoute == 'meal_plan',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyTable()),
                );
              },
            ),

            _drawerItem(
              context,
              label: 'Groceries & Inventory',
              icon: Icons.shopping_cart_outlined,
              isSelected: currentRoute == 'groceries',
              onTap: () async {
                Navigator.pop(context);

                final foodRepo = FoodRepository();

                final groceryList = await HomePage.loadGroceryItemsFromHive(
                  'groceries',
                  foodRepo,
                );

                final inventoryList = await HomePage.loadGroceryItemsFromHive(
                  'inventory',
                  foodRepo,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroceryInventoryPage(
                      initialGroceryList: groceryList,
                      initialInventory: inventoryList,
                      onBought: (_) {},
                    ),
                  ),
                );
              },
            ),
            _drawerItem(
              context,
              label: 'Manage Recipes',
              icon: Icons.calendar_month,
              isSelected: currentRoute == 'recipes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecipeManagementPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      /* -------------------- BODY -------------------- */
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(),
            const SizedBox(height: 20),
            _mealPlanPrompt(),
            const SizedBox(height: 20),
            _quickActions(),
            const SizedBox(height: 20),
            _inventoryPrompt(),
            const SizedBox(height: 20),
            todaysMealSection(),
            const SizedBox(height: 20),
            //_statsSection(),
          ],
        ),
      ),
    );
  }

  /* -------------------- UI SECTIONS -------------------- */

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecorationTheme(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $name 👋',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Age Group: $ageGroup',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _mealPlanPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.green.shade800,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Text + CTA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan your week with confidence 🌱',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set up your weekly meal plan to stay organized, save time, and '
                  'make meals that fit your dietary needs.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WeeklyTable()),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.green.shade800,
                    ),
                    label: Text(
                      'Set up weekly meal plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _statCard(
          title: 'Allergies',
          value: allergies.length.toString(),
          icon: Icons.warning_amber_rounded,
        ),
        _statCard(
          title: 'Diets',
          value: diets.length.toString(),
          icon: Icons.restaurant_menu,
        ),
        _statCard(
          title: 'Tracked Items',
          value: '0',
          icon: Icons.list_alt_rounded,
        ),
      ],
    );
  }

  Widget _inventoryPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Colors.green.shade800,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Text + CTA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay on top of your groceries 🛒',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Check what you have, see what you need, and keep your kitchen '
                  'organized with your grocery list and inventory.',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () async {
                      final foodRepo = FoodRepository();

                      final groceryList =
                          await HomePage.loadGroceryItemsFromHive(
                            'groceries',
                            foodRepo,
                          );

                      final inventoryList =
                          await HomePage.loadGroceryItemsFromHive(
                            'inventory',
                            foodRepo,
                          );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroceryInventoryPage(
                            initialGroceryList: groceryList,
                            initialInventory: inventoryList,
                            onBought: (_) {},
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.green.shade800,
                    ),
                    label: Text(
                      'View groceries & inventory',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget todaysMealSection() {
    final Box weeklyMealBox = Hive.box('weeklyMealPlan');
    final RecipeRepository recipeRepo = RecipeRepository();

    // Get today's weekday as a string like MON, TUE...
    final now = DateTime.now();
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final todayKey = days[now.weekday - 1]; // DateTime.weekday: Monday = 1

    // Load today's meals from Hive
    final Map<String, String> todayMealsMap = Map<String, String>.from(
      weeklyMealBox.get('plan', defaultValue: {})[todayKey] ?? {},
    );

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: cardDecorationTheme(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🍽️ Today's Meals",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (todayMealsMap.isEmpty)
            Text(
              'No meals planned for today! Add some in your weekly plan.',
              style: TextStyle(color: Colors.grey.shade700),
            )
          else
            FutureBuilder<Map<String, Recipe>>(
              future: _fetchTodayRecipes(todayMealsMap, recipeRepo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text(
                    'Error loading meals: ${snapshot.error}',
                    style: TextStyle(color: Colors.red.shade700),
                  );
                } else {
                  final recipes = snapshot.data!;
                  return Column(
                    children: recipes.entries.map((entry) {
                      final mealType = _capitalize(entry.key);
                      final recipeName = entry.value.name;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '$mealType: $recipeName',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  /// Helper: Fetch Recipe objects for today's meal IDs
  Future<Map<String, Recipe>> _fetchTodayRecipes(
    Map<String, String> todayMealsMap,
    RecipeRepository recipeRepo,
  ) async {
    final Map<String, Recipe> result = {};
    for (final entry in todayMealsMap.entries) {
      final recipe = await recipeRepo.getRecipe(entry.value);
      if (recipe != null) result[entry.key] = recipe;
    }
    return result;
  }

  /// Helper: Capitalize first letter of a string
  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecorationTheme(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _actionButton(
                label: 'Add Meal Recipe',
                icon: Icons.add_circle_outline,
                onPressed: _goToAddMeal,
              ),
              _actionButton(
                label: 'Add New Food',
                icon: Icons.add_circle_outline,
                onPressed: _goToAddFood,
              ),
              _actionButton(
                label: 'View History',
                icon: Icons.history,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.green.shade100, width: 2),
    );
  }
}

BoxDecoration cardDecorationTheme() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08), // subtle shadow
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(color: Colors.lightGreen.shade100, width: 1.5),
  );
}

/* -------------------- DRAWER ITEM -------------------- */

Widget _drawerItem(
  BuildContext context, {
  required String label,
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isSelected ? Colors.green.shade800 : Colors.green.shade600,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
    selected: isSelected,
    selectedTileColor: Colors.green.shade100,
    onTap: onTap,
  );
}
