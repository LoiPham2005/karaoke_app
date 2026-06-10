import 'package:flutter/material.dart';

class CategoryModel {
  final String slug;
  final String name;
  final String emoji;
  final List<Color> gradient;
  final int songCount;

  const CategoryModel({
    required this.slug,
    required this.name,
    required this.emoji,
    required this.gradient,
    required this.songCount,
  });
}
