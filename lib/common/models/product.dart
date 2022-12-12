import 'dart:convert';

import 'package:project1/common/models/mynuu_model.dart';

class Product implements MynuuModel {
  final String id;
  final String name;
  String image;
  final String description;
  final String categoryId;
  bool enabled;
  final double price;
  final int views;
  bool deleted;
  final String restaurantId;
  final String? keyword;
  int? positionInCategory;
  String? menuId;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.categoryId,
    required this.enabled,
    required this.price,
    required this.deleted,
    this.views = 0,
    required this.restaurantId,
    required this.positionInCategory,
    this.keyword,
    this.menuId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'description': description,
      'categoryId': categoryId,
      'enabled': enabled,
      'price': price,
      'views': views,
      'deleted': deleted,
      'restaurantId': restaurantId,
      'keyword': _getKeyword(),
      'positionInCategory': positionInCategory,
      'menuId': menuId,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      enabled: map['enabled'] ?? false,
      price: map['price']?.toDouble() ?? 0.0,
      views: map['views'] ?? 0,
      deleted: map['deleted'] ?? false,
      restaurantId: map['restaurantId'] ?? '',
      keyword: map['keyword'],
      positionInCategory: map['positionInCategory'],
      menuId: map['menuId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String id, String source) => Product.fromMap(
        id,
        json.decode(source),
      );

  String _getKeyword() {
    return name.toLowerCase();
  }
}
