import 'package:flutter/material.dart';

const List<IconData> _kExperienceAvailableIcons = [
  Icons.explore_rounded,
  Icons.beach_access_rounded,
  Icons.temple_buddhist_rounded,
  Icons.park_rounded,
  Icons.hiking_rounded,
  Icons.restaurant_rounded,
  Icons.waves_rounded,
  Icons.local_activity_rounded,
  Icons.landscape_rounded,
  Icons.auto_awesome_rounded,
];

IconData _resolveExperienceIcon(int? codePoint) {
  if (codePoint != null) {
    for (final icon in _kExperienceAvailableIcons) {
      if (icon.codePoint == codePoint) return icon;
    }
  }
  return Icons.explore_rounded;
}

/// Data model representing a Haven destination or excursion card.
class HavenItem {
  final String id;
  final String title;
  final String location;
  final String category;
  final String price;
  final double rating;
  final String badgeText;
  final String imageUrl;
  final String? filterCategory;

  const HavenItem({
    String? id,
    required this.title,
    required this.location,
    required this.category,
    required this.price,
    required this.rating,
    required this.badgeText,
    required this.imageUrl,
    this.filterCategory,
  }) : id = id ?? title;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'location': location,
    'category': category,
    'price': price,
    'rating': rating,
    'badgeText': badgeText,
    'imageUrl': imageUrl,
    'filterCategory': filterCategory,
  };

  factory HavenItem.fromJson(Map<String, dynamic> json) => HavenItem(
    id: json['id']?.toString(),
    title: json['title']?.toString() ?? '',
    location: json['location']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    price: json['price']?.toString() ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    badgeText: json['badgeText']?.toString() ?? 'Popular',
    imageUrl: json['imageUrl']?.toString() ?? '',
    filterCategory: json['filterCategory']?.toString(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HavenItem &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}

/// Data model representing a trending experience card.
class ExperienceItem {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String price;
  final double rating;
  final int reviewsCount;
  final IconData categoryIcon;
  final String imageUrl;
  final String? filterCategory;

  const ExperienceItem({
    String? id,
    required this.title,
    required this.category,
    required this.duration,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.categoryIcon,
    required this.imageUrl,
    this.filterCategory,
  }) : id = id ?? title;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'duration': duration,
    'price': price,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'iconCode': categoryIcon.codePoint,
    'imageUrl': imageUrl,
    'filterCategory': filterCategory,
  };

  factory ExperienceItem.fromJson(Map<String, dynamic> json) => ExperienceItem(
    id: json['id']?.toString(),
    title: json['title']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    duration: json['duration']?.toString() ?? '',
    price: json['price']?.toString() ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
    categoryIcon: _resolveExperienceIcon(json['iconCode'] as int?),
    imageUrl: json['imageUrl']?.toString() ?? '',
    filterCategory: json['filterCategory']?.toString(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceItem &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
