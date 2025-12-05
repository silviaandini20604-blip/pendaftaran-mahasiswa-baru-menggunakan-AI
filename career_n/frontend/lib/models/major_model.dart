class Major {
  final int id;
  final String name;
  final String category;
  final String description;

  Major({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  factory Major.fromJson(Map<String, dynamic> json) {
    return Major(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'] ?? '',
    );
  }
}
