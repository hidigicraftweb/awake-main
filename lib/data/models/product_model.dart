import '../../core/network/api_endpoints.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.price,
    required super.priceFormatted,
    required super.rate,
    super.thumbnail,
    super.thumbnailUrl,
    super.serviceTime,
    super.isFeatured = false,
    super.category,
    super.about,
    super.options = const [],
  });

  /// Factory for list item response (no options)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final thumbnailUrlPath = json['thumbnail_url'] as String?;
    final fullThumbnailUrl = ApiEndpoints.getFullStorageUrl(thumbnailUrlPath);

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: json['price'] as int,
      priceFormatted: json['price_formatted'] as String? ?? '',
      rate: (json['rate'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String?,
      thumbnailUrl: fullThumbnailUrl,
      serviceTime: json['service_time'] as int?,
      isFeatured: json['is_featured'] as bool? ?? false,
      category: json['category'] != null
          ? ProductCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>)
          : null,
      about: json['about'] as String?,
    );
  }

  /// Factory for detail response (includes options)
  factory ProductModel.fromDetailJson(Map<String, dynamic> json) {
    final thumbnailUrlPath = json['thumbnail_url'] as String?;
    final fullThumbnailUrl = ApiEndpoints.getFullStorageUrl(thumbnailUrlPath);

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: json['price'] as int,
      priceFormatted: json['price_formatted'] as String? ?? '',
      rate: (json['rate'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String?,
      thumbnailUrl: fullThumbnailUrl,
      serviceTime: json['service_time'] as int?,
      isFeatured: json['is_featured'] as bool? ?? false,
      category: json['category'] != null
          ? ProductCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>)
          : null,
      about: json['about'] as String?,
      options: json['options'] != null
          ? (json['options'] as List)
              .map((group) => ProductOptionGroupModel.fromJson(
                  group as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'price_formatted': priceFormatted,
      'rate': rate,
      'thumbnail': thumbnail,
      'thumbnail_url': thumbnailUrl,
      'service_time': serviceTime,
      'is_featured': isFeatured,
      'category': category != null
          ? {
              'id': category!.id,
              'name': category!.name,
              'slug': category!.slug,
            }
          : null,
      'about': about,
      'options': options
          .map((group) => {
                'type': group.type,
                'items': group.items
                    .map((item) => {
                          'id': item.id,
                          'name': item.name,
                          'price': item.price,
                          'price_formatted': item.priceFormatted,
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      slug: slug,
      price: price,
      priceFormatted: priceFormatted,
      rate: rate,
      thumbnail: thumbnail,
      thumbnailUrl: thumbnailUrl,
      serviceTime: serviceTime,
      isFeatured: isFeatured,
      category: category,
      about: about,
      options: options,
    );
  }
}

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
    );
  }
}

class ProductOptionGroupModel extends ProductOptionGroup {
  const ProductOptionGroupModel({
    required super.type,
    required super.items,
  });

  factory ProductOptionGroupModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroupModel(
      type: json['type'] as String,
      items: (json['items'] as List)
          .map((item) =>
              ProductOptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductOptionModel extends ProductOption {
  const ProductOptionModel({
    required super.id,
    required super.name,
    required super.price,
    required super.priceFormatted,
  });

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as int,
      priceFormatted: json['price_formatted'] as String? ?? '',
    );
  }
}
