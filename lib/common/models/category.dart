import 'dart:convert';

import 'package:project1/common/models/mynuu_model.dart';

class ProductCategory implements MynuuModel {
  final String id;
  final String name;
  final bool status;
  final String restaurantId;

  ProductCategory({
    required this.id,
    required this.name,
    required this.status,
    required this.restaurantId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {'name': name, 'status': status, 'restaurantId': restaurantId};
  }

  factory ProductCategory.fromMap(String id, Map<String, dynamic> map) {
    return ProductCategory(
      id: id,
      name: map['name'] ?? '',
      status: map['status'] ?? false,
      restaurantId: map['restaurantId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductCategory.fromJson(String id, String source) =>
      ProductCategory.fromMap(
        id,
        json.decode(source),
      );
}
