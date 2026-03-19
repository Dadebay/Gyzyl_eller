class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final List<CategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      parentId: json['parent_id'],
      subcategories: (json['sub_categories'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
    );
  }
}

class LocationModel {
  final int id;
  final String name;
  final List<LocationModel> etraps;

  LocationModel({
    required this.id,
    required this.name,
    this.etraps = const [],
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    // Support both {id, name} (api/welayats) and {value, label} (lang/locations) formats
    final id = int.tryParse(
            (json['id'] ?? json['value'])?.toString() ?? '0') ??
        0;
    final name = (json['name'] ?? json['label'] ?? '').toString();
    return LocationModel(
      id: id,
      name: name,
      etraps: (json['etraps'] as List? ?? [])
          .map((e) => LocationModel.fromJson(e))
          .toList(),
    );
  }
}
