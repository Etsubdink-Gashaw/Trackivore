import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/nutrient.dart';
import '../database/default_nutrients.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  static Future<Food?> show(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodPage()),
    );
  }

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController _nameController = TextEditingController();

  late final List<Nutrient> _nutrients;
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _nutrients = defaultNutrients
        .map((n) => Nutrient(name: n.name, amount: 0, unit: n.unit))
        .toList();

    _controllers = {for (var n in _nutrients) n.name: TextEditingController()};
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _toast('Food name is required');
      return;
    }

    final nutrients = <Nutrient>[];

    for (final n in _nutrients) {
      final text = _controllers[n.name]!.text.trim();
      if (text.isEmpty) continue;

      final value = double.tryParse(text);
      if (value == null || value <= 0) continue;

      nutrients.add(Nutrient(name: n.name, amount: value, unit: n.unit));
    }

    final food = Food(id: '', name: name, nutrients: nutrients);

    if (nutrients.isEmpty) {
      _toast('Please add at least one nutrient');
      return;
    }

    Navigator.pop(context, food);
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Food'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _softInput(controller: _nameController, hint: 'Food name'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _nutrients.length,
                itemBuilder: (_, i) {
                  final n = _nutrients[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Nutrient name
                        Expanded(
                          child: Text(
                            n.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                        // Input box (fixed width)
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _controllers[n.name],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Unit (fixed width)
                        SizedBox(
                          width: 40,
                          child: Text(
                            n.unit,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Food'),
                style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF43A047),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softInput({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none,),
      ),
    );
  }
}
