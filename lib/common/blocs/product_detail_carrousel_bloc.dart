import 'package:flutter/material.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/services/landing_service.dart';

class ProductDetailCarrouselBloc {
  ValueNotifier<bool> loading = ValueNotifier(false);
  final CloudFirestoreService _service;

  ProductDetailCarrouselBloc() : _service = CloudFirestoreService();

  Stream<List<Product>> streamProductByCategory(String categoryId) {
    return _service.streamEnabledProductByCategory(categoryId);
  }

  Future<Restaurant> getRestaurantById(String id) async {
    return await _service.getRestaurantById(id);
  }
}
