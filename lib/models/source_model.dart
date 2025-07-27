// lib/models/source_model.dart
class Source {
  final int? id;
  final String? name;
  final String? description;
  final String? slug;
  final int? totalStories; // Added for category data
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Source({
    this.id,
    this.name,
    this.description,
    this.slug,
    this.totalStories,
    this.createdAt,
    this.updatedAt,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      // Handle both category and regular source formats
      id: json['id'] != null 
          ? int.tryParse(json['id'].toString()) 
          : json['category_id'] != null
              ? int.tryParse(json['category_id'].toString())
              : null,
      
      // Handle both name formats
      name: json['name']?.toString() ?? json['category_name']?.toString(),
      
      description: json['description']?.toString(),
      slug: json['slug']?.toString(),
      
      // Add total stories for categories
      totalStories: json['total_stories'] != null 
          ? int.tryParse(json['total_stories'].toString())
          : null,
          
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'total_stories': totalStories,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Source(id: $id, name: $name, description: $description, totalStories: $totalStories)';
  }
}