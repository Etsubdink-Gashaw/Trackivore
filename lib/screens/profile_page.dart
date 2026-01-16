import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../login.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String? ageGroup;
  final Set<String> allergies;
  final Set<String> diets;

  const ProfilePage({
    super.key,
    required this.name,
    required this.ageGroup,
    required this.allergies,
    required this.diets,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  String? _selectedAgeGroup;
  Set<String> _selectedAllergies = {};
  Set<String> _selectedDiets = {};
  bool _isEditing = false;
  bool _isSaving = false;

  final List<String> _availableAgeGroups = [
    '3-5 Years',
    '6-12 Years',
    '13-18 Years',
    '18+ Years',
  ];

  final List<String> _availableAllergies = ['Dairy', 'Nuts', 'Eggs'];
  final List<String> _availableDiets = ['Vegan', 'Halal'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _selectedAgeGroup = widget.ageGroup;
    _selectedAllergies = Set<String>.from(widget.allergies);
    _selectedDiets = Set<String>.from(widget.diets);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a profile name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final box = Hive.box('profileBox');
      await box.put('name', name);
      await box.put('ageGroup', _selectedAgeGroup);
      await box.put('allergies', _selectedAllergies.toList());
      await box.put('diets', _selectedDiets.toList());

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF43A047),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = widget.name;
      _selectedAgeGroup = widget.ageGroup;
      _selectedAllergies = Set<String>.from(widget.allergies);
      _selectedDiets = Set<String>.from(widget.diets);
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: _cancelEdit,
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileHeader(),
            const SizedBox(height: 24),
            _nameCard(),
            const SizedBox(height: 16),
            _ageGroupCard(),
            const SizedBox(height: 16),
            _allergiesCard(),
            const SizedBox(height: 16),
            _dietsCard(),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              _saveButton(),
            ],
            const SizedBox(height: 24),
            _signOutButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.transparent,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'Your Profile'
                      : _nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedAgeGroup ?? 'Age not set',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline,
                  color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Profile Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditing
              ? TextField(
                  controller: _nameController,
                  maxLength: 15,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter profile name',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                )
              : Text(
                  _nameController.text.isEmpty
                      ? 'Not set'
                      : _nameController.text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _ageGroupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cake_outlined,
                  color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Age Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditing
              ? DropdownButtonFormField<String>(
                  value: _selectedAgeGroup,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _availableAgeGroups.map((ageGroup) {
                    return DropdownMenuItem<String>(
                      value: ageGroup,
                      child: Text(ageGroup),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedAgeGroup = value);
                  },
                  icon: const Icon(Icons.arrow_drop_down),
                )
              : Text(
                  _selectedAgeGroup ?? 'Not set',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _allergiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_outlined,
                  color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Allergies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditing
              ? _buildChips(
                  _availableAllergies,
                  _selectedAllergies,
                  (allergy) {
                    setState(() {
                      if (_selectedAllergies.contains(allergy)) {
                        _selectedAllergies.remove(allergy);
                      } else {
                        _selectedAllergies.add(allergy);
                      }
                    });
                  },
                )
              : _selectedAllergies.isEmpty
                  ? Text(
                      'None',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedAllergies.map((allergy) {
                        return Chip(
                          label: Text(allergy),
                          backgroundColor: Colors.red.shade50,
                          labelStyle: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(color: Colors.red.shade300),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _dietsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_outlined,
                  color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Dietary Restrictions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _isEditing
              ? _buildChips(
                  _availableDiets,
                  _selectedDiets,
                  (diet) {
                    setState(() {
                      if (_selectedDiets.contains(diet)) {
                        _selectedDiets.remove(diet);
                      } else {
                        _selectedDiets.add(diet);
                      }
                    });
                  },
                )
              : _selectedDiets.isEmpty
                  ? Text(
                      'None',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedDiets.map((diet) {
                        return Chip(
                          label: Text(diet),
                          backgroundColor: Colors.green.shade50,
                          labelStyle: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(color: Colors.green.shade300),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildChips(
    List<String> available,
    Set<String> selected,
    Function(String) onTap,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: available.map((item) {
        final isSelected = selected.contains(item);
        return FilterChip(
          label: Text(item, style: const TextStyle(fontSize: 14)),
          selected: isSelected,
          selectedColor: Colors.green.shade100,
          backgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(
            color: isSelected ? Colors.green.shade600 : Colors.transparent,
            width: 2,
          ),
          onSelected: (selected) => onTap(item),
        );
      }).toList(),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF43A047),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _signOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _signOut,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: BorderSide(color: Colors.red.shade300, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.lightGreen.shade100, width: 1.5),
    );
  }
}
