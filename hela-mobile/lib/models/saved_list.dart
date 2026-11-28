import 'package:flutter/material.dart';

/// Data model representing a user-created custom list or collection in HELA.
///
/// Allows travelers to organize their saved destinations, tours, eco-stays,
/// and excursions into custom themed categories (e.g., "Beach Escapes",
/// "Surf Spots", "Honeymoon Wishlist", "Temple Run").
class CustomSavedList {
  final String id;
  final String name;
  final String? description;
  final IconData icon;
  final Color color;
  final List<String> itemTitles;
  final DateTime createdAt;

  CustomSavedList({
    required this.id,
    required this.name,
    this.description,
    this.icon = Icons.folder_rounded,
    this.color = const Color(0xFF00443E),
    List<String>? itemTitles,
    DateTime? createdAt,
  }) : itemTitles = itemTitles ?? [],
       createdAt = createdAt ?? DateTime.now();

  CustomSavedList copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    List<String>? itemTitles,
  }) {
    return CustomSavedList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      itemTitles: itemTitles != null
          ? List.from(itemTitles)
          : List.from(this.itemTitles),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'iconCode': icon.codePoint,
    'colorValue': color.toARGB32(),
    'itemTitles': itemTitles,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomSavedList.fromJson(Map<String, dynamic> json) {
    final code = json['iconCode'] as int?;
    IconData matchedIcon = Icons.folder_rounded;
    if (code != null) {
      for (final ic in kCustomListAvailableIcons) {
        if (ic.codePoint == code) {
          matchedIcon = ic;
          break;
        }
      }
    }

    return CustomSavedList(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: matchedIcon,
      color: Color(json['colorValue'] as int? ?? 0xFF00443E),
      itemTitles:
          (json['itemTitles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Curated icon options for custom list creation.
const List<IconData> kCustomListAvailableIcons = [
  Icons.beach_access_rounded,
  Icons.temple_buddhist_rounded,
  Icons.park_rounded,
  Icons.surfing_rounded,
  Icons.hiking_rounded,
  Icons.hotel_rounded,
  Icons.restaurant_rounded,
  Icons.camera_alt_rounded,
  Icons.favorite_rounded,
  Icons.auto_awesome_rounded,
  Icons.explore_rounded,
  Icons.wb_sunny_rounded,
];

/// Curated color options for custom list creation matching Stitch styling.
const List<Color> kCustomListAvailableColors = [
  Color(0xFF00443E), // Hela Deep Pine
  Color(0xFF0D9488), // Teal
  Color(0xFF059669), // Emerald
  Color(0xFFD97706), // Amber
  Color(0xFFE11D48), // Crimson Rose
  Color(0xFF0284C7), // Sky Blue
  Color(0xFF7C3AED), // Violet
  Color(0xFFEA580C), // Ceylon Sunset Coral
];
