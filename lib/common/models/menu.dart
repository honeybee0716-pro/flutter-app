import 'dart:convert';

import 'package:project1/common/models/mynuu_model.dart';

class Menu implements MynuuModel {
  final String id;
  final String name;
  final String restaurantId;

  Menu({
    required this.id,
    required this.name,
    required this.restaurantId,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'restaurantId': restaurantId,
    };
  }

  factory Menu.fromMap(String id, Map<String, dynamic> map) {
    return Menu(
      id: id,
      name: map['name'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Menu.fromJson(String id, String source) => Menu.fromMap(
        id,
        json.decode(source),
      );
}
