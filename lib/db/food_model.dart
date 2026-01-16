class Food {
  final int id;
  final String name;

  Food({required this.id, required this.name});

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(id: map['id'], name: map['name']);
  }
}
