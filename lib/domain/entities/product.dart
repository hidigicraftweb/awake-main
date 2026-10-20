import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String slug;
  final int price;
  final String priceFormatted;
  final double rate;
  final String? thumbnail;
  final String? thumbnailUrl;
  final int? serviceTime;
  final bool isFeatured;
  final ProductCategory? category;
  final String? about;
  final List<ProductOptionGroup> options;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.priceFormatted,
    required this.rate,
    this.thumbnail,
    this.thumbnailUrl,
    this.serviceTime,
    this.isFeatured = false,
    this.category,
    this.about,
    this.options = const [],
  });

  /// Get options by type (e.g., 'size', 'dairy', 'sweetness', 'ice')
  ProductOptionGroup? getOptionsByType(String type) {
    try {
      return options.firstWhere((group) => group.type == type);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        price,
        priceFormatted,
        rate,
        thumbnail,
        thumbnailUrl,
        serviceTime,
        isFeatured,
        category,
        about,
        options,
      ];
}

class ProductCategory extends Equatable {
  final int id;
  final String name;
  final String slug;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, name, slug];
}

class ProductOptionGroup extends Equatable {
  final String type;
  final List<ProductOption> items;

  const ProductOptionGroup({
    required this.type,
    required this.items,
  });

  @override
  List<Object?> get props => [type, items];
}

class ProductOption extends Equatable {
  final int id;
  final String name;
  final int price;
  final String priceFormatted;

  const ProductOption({
    required this.id,
    required this.name,
    required this.price,
    required this.priceFormatted,
  });

  @override
  List<Object?> get props => [id, name, price, priceFormatted];
}
