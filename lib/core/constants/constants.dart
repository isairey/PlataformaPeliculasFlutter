import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String originalImageBaseUrl =
      'https://image.tmdb.org/t/p/original';

  static String get apiKey => dotenv.env['TMDB_API_KEY_1'] ?? '';
}

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color primary = Color(0xFFE50914);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color navBackground = Color(0xCC000000);
  static const Color grey = Color(0xFF808080);
}
