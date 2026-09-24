import 'package:flutter/material.dart';

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

  const HavenItem({
    String? id,
    required this.title,
    required this.location,
    required this.category,
    required this.price,
    required this.rating,
    required this.badgeText,
    required this.imageUrl,
  }) : id = id ?? title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HavenItem && runtimeType == other.runtimeType && title == other.title;

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
  }) : id = id ?? title;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExperienceItem && runtimeType == other.runtimeType && title == other.title;

  @override
  int get hashCode => title.hashCode;
}
