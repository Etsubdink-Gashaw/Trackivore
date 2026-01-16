import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/grocery_item.dart';
import '../data/food_repository.dart';

class GroceryInventoryPage extends StatefulWidget {
  final List<GroceryItem> initialGroceryList;
  final List<GroceryItem> initialInventory;
  final Function(List<GroceryItem>) onBought;

  const GroceryInventoryPage({
    super.key,
    required this.initialGroceryList,
    required this.onBought,
    this.initialInventory = const [],
  });

  @override
  State<GroceryInventoryPage> createState() => _GroceryInventoryPageState();
}

class _GroceryInventoryPageState extends State<GroceryInventoryPage> {
  final Box _box = Hive.box('inventoryBox');
  final FoodRepository _foodRepo = FoodRepository();

  late List<GroceryItem> groceryList;
  final List<GroceryItem> inventoryList = [];

  @override
  void initState() {
    super.initState();
    _loadFromHive();
  }

  /* -------------------- HIVE -------------------- */

  Map<String, dynamic> _toMap(GroceryItem item) => {
    'foodId': item.food.id,
    'quantity': item.neededQuantity,
  };

  Future<GroceryItem?> _fromMap(Map map) async {
    final food = await _foodRepo.getFood(map['foodId']);
    if (food == null) return null;
    return GroceryItem(food: food, neededQuantity: map['quantity']);
  }

  Future<void> _loadFromHive() async {
    final storedInventory = _box.get('inventory', defaultValue: []) as List;
    final storedGroceries = _box.get('groceries', defaultValue: []) as List;

    inventoryList.clear();
    groceryList = [];

    for (final m in storedInventory) {
      final i = await _fromMap(m);
      if (i != null) inventoryList.add(i);
    }

    for (final m in storedGroceries) {
      final i = await _fromMap(m);
      if (i != null) groceryList.add(i);
    }

    if (inventoryList.isEmpty && groceryList.isEmpty) {
      groceryList = List.from(widget.initialGroceryList);
      inventoryList.addAll(widget.initialInventory);
      _saveToHive();
    }

    setState(() {});
  }

  void _saveToHive() {
    _box.put('inventory', inventoryList.map(_toMap).toList());
    _box.put('groceries', groceryList.map(_toMap).toList());
  }

  /* -------------------- ACTIONS -------------------- */

  void _moveToInventory(GroceryItem item) {
    setState(() {
      groceryList.remove(item);
      inventoryList.add(item);
      _saveToHive();
    });
  }

  void _removeFromInventory(GroceryItem item) {
    setState(() {
      inventoryList.remove(item);
      _saveToHive();
    });
  }

  /* -------------------- UI ITEMS -------------------- */

  Widget _inventoryItem(GroceryItem item) {
    return Dismissible(
      key: ValueKey('inv-${item.food.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeFromInventory(item),
      child: _card(text: item.food.name, icon: Icons.remove),
    );
  }

  Widget _groceryItem(GroceryItem item) {
    return Dismissible(
      key: ValueKey('gro-${item.food.id}'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => _moveToInventory(item),
      child: _card(text: item.food.name, icon: Icons.check),
    );
  }

  Widget _card({required String text, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 16)),
            Icon(icon, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  /* -------------------- PAGE -------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Grocery & Inventory',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Inventory List',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...inventoryList.map(_inventoryItem),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grocery List',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF1E6F4E),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...groceryList.map(_groceryItem),
          ],
        ),
      ),
    );
  }
}
