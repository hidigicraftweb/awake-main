import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CartCafe {
  final int id;
  final String name;
  final String? address;
  final String? imageUrl;
  final bool isOpen;

  CartCafe({
    required this.id,
    required this.name,
    this.address,
    this.imageUrl,
    this.isOpen = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'isOpen': isOpen,
    };
  }

  factory CartCafe.fromMap(Map<String, dynamic> map) {
    return CartCafe(
      id: map['id'] as int,
      name: map['name'] as String,
      address: map['address'] as String?,
      imageUrl: map['imageUrl'] as String?,
      isOpen: map['isOpen'] as bool? ?? true,
    );
  }
}

class CartItem {
  final String id;
  final int? productId;
  final String name;
  final String image;
  final int basePrice;
  int quantity;
  final Map<String, dynamic>? options;

  CartItem({
    required this.id,
    this.productId,
    required this.name,
    required this.image,
    required this.basePrice,
    this.quantity = 1,
    this.options,
  });

  int get unitPrice {
    int price = basePrice;
    if (options != null) {
      price += (options!['sizePrice'] as int? ?? 0);
      price += (options!['dairyPrice'] as int? ?? 0);
      price += (options!['sweetnessPrice'] as int? ?? 0);
      price += (options!['icePrice'] as int? ?? 0);
    }
    return price;
  }

  int get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'image': image,
      'basePrice': basePrice,
      'quantity': quantity,
      'options': options,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      productId: map['productId'] as int?,
      name: map['name'] as String,
      image: map['image'] as String,
      basePrice: map['basePrice'] as int,
      quantity: map['quantity'] as int? ?? 1,
      options: map['options'] as Map<String, dynamic>?,
    );
  }
}

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _storageKey = 'cart_items_v2';
  static const String _cafeStorageKey = 'cart_cafe';

  final List<CartItem> _items = [];
  CartCafe? _selectedCafe;
  bool _isInitialized = false;

  List<CartItem> get items => _items;
  CartCafe? get selectedCafe => _selectedCafe;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Initialize cart by loading from local storage
  Future<void> init() async {
    if (_isInitialized) return;
    await _loadFromStorage();
    _isInitialized = true;
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cart items
      final cartJson = prefs.getString(_storageKey);
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> cartList = jsonDecode(cartJson);
        _items.clear();
        for (final item in cartList) {
          final cartItem = CartItem.fromMap(item as Map<String, dynamic>);
          // Only add valid items (with non-empty required fields)
          if (cartItem.name.isNotEmpty && cartItem.basePrice > 0) {
            _items.add(cartItem);
          }
        }
      }

      // Load selected cafe
      final cafeJson = prefs.getString(_cafeStorageKey);
      if (cafeJson != null && cafeJson.isNotEmpty) {
        final cafeMap = jsonDecode(cafeJson) as Map<String, dynamic>;
        _selectedCafe = CartCafe.fromMap(cafeMap);
      }
    } catch (e) {
      // If there's an error loading, start with empty cart
      _items.clear();
      _selectedCafe = null;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartList = _items.map((item) => item.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(cartList));

      // Save selected cafe
      if (_selectedCafe != null) {
        await prefs.setString(_cafeStorageKey, jsonEncode(_selectedCafe!.toMap()));
      } else {
        await prefs.remove(_cafeStorageKey);
      }
    } catch (e) {
      // Silently fail - cart will still work in memory
    }
  }

  /// Set the selected cafe for the cart
  Future<void> setSelectedCafe(CartCafe cafe) async {
    _selectedCafe = cafe;
    await _saveToStorage();
  }

  Future<void> addItem(CartItem item) async {
    // Check if item with same options already exists
    final existingIndex = _items.indexWhere((i) =>
      i.name == item.name &&
      _optionsMatch(i.options, item.options)
    );

    if (existingIndex != -1) {
      // Update quantity of existing item
      _items[existingIndex].quantity += item.quantity;
    } else {
      // Add new item
      _items.add(item);
    }

    await _saveToStorage();
  }

  bool _optionsMatch(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a['size'] == b['size'] &&
           a['sweetness'] == b['sweetness'] &&
           a['ice'] == b['ice'] &&
           a['dairy'] == b['dairy'];
  }

  Future<void> removeItem(int index) async {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      await _saveToStorage();
    }
  }

  Future<void> updateQuantity(int index, int quantity) async {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      await _saveToStorage();
    }
  }

  Future<void> clear() async {
    _items.clear();
    _selectedCafe = null;
    await _saveToStorage();
  }
}
