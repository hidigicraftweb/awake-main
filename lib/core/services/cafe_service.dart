import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CafeService {
  static final CafeService _instance = CafeService._internal();
  factory CafeService() => _instance;
  CafeService._internal();

  static const String _selectedCafeKey = 'selected_cafe';

  Map<String, dynamic>? _selectedCafe;

  // Default cafe (with integer ID for backend compatibility)
  static final Map<String, dynamic> defaultCafe = {
    'id': 1, // Backend cafe ID
    'slug': 'sudirman',
    'name': 'Awake Sudirman',
    'address': 'Jl. Jend. Sudirman No. 52',
    'isOpen': true,
  };

  // Available cafes (with integer IDs for backend compatibility)
  static final List<Map<String, dynamic>> availableCafes = [
    {
      'id': 1,
      'slug': 'sudirman',
      'name': 'Awake Sudirman',
      'address': 'Jl. Jend. Sudirman No. 52',
      'isOpen': true,
    },
    {
      'id': 2,
      'slug': 'scbd',
      'name': 'Awake SCBD',
      'address': 'SCBD Area, Lot 14',
      'isOpen': true,
    },
    {
      'id': 3,
      'slug': 'kemang',
      'name': 'Awake Kemang',
      'address': 'Jl. Kemang Raya No. 18',
      'isOpen': false,
    },
    {
      'id': 4,
      'slug': 'senayan',
      'name': 'Awake Senayan',
      'address': 'Senayan City Mall, Lt. 1',
      'isOpen': true,
    },
  ];

  Map<String, dynamic> get selectedCafe => _selectedCafe ?? defaultCafe;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final cafeJson = prefs.getString(_selectedCafeKey);
    if (cafeJson != null) {
      _selectedCafe = jsonDecode(cafeJson);
    }
  }

  Future<void> setSelectedCafe(Map<String, dynamic> cafe) async {
    _selectedCafe = cafe;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCafeKey, jsonEncode(cafe));
  }

  Future<void> clearSelectedCafe() async {
    _selectedCafe = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCafeKey);
  }
}
