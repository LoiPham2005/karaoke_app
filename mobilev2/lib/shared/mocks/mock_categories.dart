import 'package:flutter/material.dart';
import 'package:karaoke/shared/models/category_model.dart';

const List<CategoryModel> mockCategories = [
  CategoryModel(
    slug: 'vpop',
    name: 'V-Pop',
    emoji: '🎤',
    gradient: [Color(0xFFEC4899), Color(0xFFF43F5E)],
    songCount: 1245,
  ),
  CategoryModel(
    slug: 'bolero',
    name: 'Bolero',
    emoji: '🎷',
    gradient: [Color(0xFFF59E0B), Color(0xFFF97316)],
    songCount: 856,
  ),
  CategoryModel(
    slug: 'trutinh',
    name: 'Trữ Tình',
    emoji: '🌸',
    gradient: [Color(0xFFA855F7), Color(0xFFEC4899)],
    songCount: 734,
  ),
  CategoryModel(
    slug: 'usuk',
    name: 'US-UK',
    emoji: '🌍',
    gradient: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    songCount: 2156,
  ),
  CategoryModel(
    slug: 'kpop',
    name: 'K-Pop',
    emoji: '💜',
    gradient: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
    songCount: 678,
  ),
  CategoryModel(
    slug: 'edm',
    name: 'EDM',
    emoji: '🎧',
    gradient: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    songCount: 543,
  ),
  CategoryModel(
    slug: 'rap',
    name: 'Rap Việt',
    emoji: '🎙️',
    gradient: [Color(0xFF10B981), Color(0xFF14B8A6)],
    songCount: 421,
  ),
  CategoryModel(
    slug: 'nhactre',
    name: 'Nhạc Trẻ',
    emoji: '✨',
    gradient: [Color(0xFFD946EF), Color(0xFFEC4899)],
    songCount: 1567,
  ),
];
