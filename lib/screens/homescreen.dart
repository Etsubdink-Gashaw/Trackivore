import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'recipe_page.dart';
import 'package:trackivore/screens/add_food.dart';
import 'package:trackivore/screens/add_recipe.dart';

import 'grocery_inventory_list.dart';
import 'profile_page.dart';
import 'weekly_table.dart';
import 'chat.dart';

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

  final String? name;
  final String? ageGroup;
  final Set<String>? allergies;
  final Set<String>? diets;

  @override
  State<HomePage> createState() => _HomePageState();

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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const String currentRoute = 'home';

  late String name;
  late String ageGroup;
  late Set<String> allergies;
  late Set<String> diets;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfileData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadProfileData();
    }
  }

  void _loadProfileData() {
    final box = Hive.box('profileBox');

    setState(() {
      name = widget.name ?? box.get('name', defaultValue: '');
      ageGroup = widget.ageGroup ?? box.get('ageGroup', defaultValue: '');

      allergies =
          widget.allergies ??
          (box.get('allergies', defaultValue: []) as List)
              .cast<String>()
              .toSet();

      diets =
          widget.diets ??
          (box.get('diets', defaultValue: []) as List).cast<String>().toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Color(0xFF43A047),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Trackivore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
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
              ).then((_) {
                _loadProfileData();
              });
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(),
            const SizedBox(height: 16),
            _mealPlanPrompt(),
            const SizedBox(height: 16),
            _quickActionsCard(),
            const SizedBox(height: 16),
            _inventoryPrompt(),
            const SizedBox(height: 16),
            todaysMealSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    String emoji = '☀️';
    
    if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon';
      emoji = '🌤️';
    } else if (hour >= 17) {
      greeting = 'Good evening';
      emoji = '🌙';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $emoji',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  name.isEmpty ? 'Welcome!' : name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (ageGroup.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ageGroup,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 32,
            ),
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.purple.shade600,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan your week 📅',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stay organized and save time with your weekly meal plan!',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WeeklyTable()),
                    ).then((_) => _loadProfileData());
                  },
                  icon: Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Set up meal plan',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.purple.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: Colors.orange.shade600, size: 24),
              SizedBox(width: 8),
              const Text(
                'Quick Actions ⚡',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _actionTile(
            icon: Icons.add_circle,
            iconColor: Colors.green.shade600,
            label: 'Add Meal Recipe',
            subtitle: 'Create a new recipe',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddRecipePage()),
              ).then((_) => _loadProfileData());
            },
          ),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.restaurant,
            iconColor: Colors.blue.shade600,
            label: 'Add New Food',
            subtitle: 'Add ingredients to database',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddFoodPage()),
              ).then((_) => _loadProfileData());
            },
          ),
          const SizedBox(height: 12),
          _actionTile(
            icon: Icons.chat_bubble,
            iconColor: Colors.purple.shade600,
            label: 'Chat with AI',
            subtitle: 'Get nutrition advice',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              ).then((_) => _loadProfileData());
            },
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _inventoryPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart,
              color: Colors.orange.shade600,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shopping List 🛒',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keep track of what you need and what you have!',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
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
                    ).then((_) => _loadProfileData());
                  },
                  icon: Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'View groceries',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange.shade600,
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

    final now = DateTime.now();
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final todayKey = days[now.weekday - 1];

    final Map<String, String> todayMealsMap = Map<String, String>.from(
      weeklyMealBox.get('plan', defaultValue: {})[todayKey] ?? {},
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.green.shade600, size: 24),
              SizedBox(width: 8),
              Text(
                "Today's Meals 🍽️",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todayMealsMap.isEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No meals planned for today! Add some in your weekly plan.',
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
                    ),
                  ),
                ],
              ),
            )
          else
            FutureBuilder<Map<String, Recipe>>(
              future: _fetchTodayRecipes(todayMealsMap, recipeRepo),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error loading meals', style: TextStyle(color: Colors.red));
                } else {
                  final recipes = snapshot.data!;
                  return Column(
                    children: recipes.entries.map((entry) {
                      final mealType = _capitalize(entry.key);
                      final recipeName = entry.value.name;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mealType,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    recipeName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF43A047)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF1B5E20),
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '  $name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 36),
                  Text(
                    'Trackivore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
              ).then((_) => _loadProfileData());
            },
          ),
          _drawerItem(
            context,
            label: 'Chat',
            icon: Icons.chat,
            isSelected: currentRoute == 'chat',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              ).then((_) => _loadProfileData());
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
              ).then((_) => _loadProfileData());
            },
          ),
          _drawerItem(
            context,
            label: 'Manage Recipes',
            icon: Icons.restaurant_menu,
            isSelected: currentRoute == 'recipes',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RecipeManagementPage(),
                ),
              ).then((_) => _loadProfileData());
            },
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}

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
      color: isSelected ? Color(0xFF1B5E20) : Color(0xFF43A047),
    ),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
    selected: isSelected,
    selectedTileColor: Color(0xFFA6EBAF),
    onTap: onTap,
  );
}
