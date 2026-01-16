// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'package:hive/hive.dart';

class Setup extends StatefulWidget {
  const Setup({super.key});
  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final _nameController = TextEditingController();
  String? selectedValue = '3-5 Years';
  Set<String> selectedFood = {};
  List<String> availableFood = ['Dairy', 'Nuts', 'Eggs'];
  Set<String> selectedDiets = {};
  List<String> availableDiets = ['Vegan', 'Halal'];
  bool isSelected = false;

  void _saveAndNavigate() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a profile name')),
      );
      return;
    }
    final box = Hive.box('profileBox');

    await box.put('name', name);
    await box.put('ageGroup', selectedValue);
    await box.put('allergies', selectedFood.toList());
    await box.put('diets', selectedDiets.toList());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          name: name,
          ageGroup: selectedValue,
          allergies: selectedFood,
          diets: selectedDiets,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF43A047),
              Color(0xFF1B5E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Profile Setup',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Profile Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          maxLength: 15,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Enter name for profile',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF43A047),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        const Text(
                          'Age Group',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          dropdownColor: Colors.white,
                          elevation: 8,
                          value: selectedValue,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF43A047),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: const Text(
                            'Select an option',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          items: <String>[
                            '3-5 Years',
                            '6-12 Years',
                            '13-18 Years',
                            '18+ Years',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down, size: 24),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Allergies',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chips(
                          available: availableFood,
                          selecteds: selectedFood,
                          onChipTap: () {},
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Dietary Restrictions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chips(
                          available: availableDiets,
                          selecteds: selectedDiets,
                          onChipTap: () {},
                        ),
                        const SizedBox(height: 30),
                        saveProfile(_saveAndNavigate),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Chips extends StatefulWidget {
  const Chips({
    super.key,
    required this.available,
    required this.selecteds,
    required this.onChipTap,
  });

  final List<String> available;
  final Set<String> selecteds;

  final VoidCallback onChipTap;

  @override
  State<Chips> createState() => ChipsState();
}

class ChipsState extends State<Chips> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.available.map((filter) {
          final isSelected = widget.selecteds.contains(filter);

          return FilterChip(
            label: Text(filter, style: const TextStyle(fontSize: 14)),
            selected: isSelected,
            selectedColor: const Color(0xFFA6EBAF),
            backgroundColor: const Color(0xFFD9D9D9),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(
              color: isSelected
                  ? const Color(0xFF43A047)
                  : Colors.transparent,
              width: 2,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (selected) {
              setState(() {
                selected
                    ? widget.selecteds.add(filter)
                    : widget.selecteds.remove(filter);
              });
            },
          );
        }).toList(),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Add', style: TextStyle(fontSize: 14)),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD9D9D9), width: 2),
          onPressed: widget.onChipTap,
        ),
      ],
    );
  }
}

Widget saveProfile(VoidCallback onSave) {
  return SizedBox(
    width: double.infinity,
    height: 45,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFF43A047),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      onPressed: onSave,
      child: const Text(
        'Save Profile',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
