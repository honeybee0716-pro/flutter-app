import 'package:flutter/material.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/services/landing_service.dart';

class HomeBloc {
  ValueNotifier<bool> loading = ValueNotifier(false);

  ValueNotifier<bool> searchIsComplete = ValueNotifier(false);
  final CloudFirestoreService _service;

  HomeBloc() : _service = CloudFirestoreService();

  Stream<List<ProductCategory>> streamCategories(String restaurantId,
      {int? limit}) {
    return _service.streamCategories(
      restaurantId,
      limit: limit,
    );
  }

  Future<List<Menu>> getMenus(String restaurantId) {
    return _service.getMenus(restaurantId);
  }

  Future<List<ProductCategory>> getCategories(String restaurantId) {
    return _service.getCategories(restaurantId);
  }

  Future<Restaurant> getRestaurantById(String id) async {
    return await _service.getRestaurantById(id);
  }

  Stream<List<Product>> streamProductByCategory(String categoryId) {
    return _service.streamEnabledProductByCategory(categoryId);
  }

  Stream<Restaurant> streamRestaurantById(
    String id,
  ) {
    return _service.streamRestaurantById(id);
  }

  Future<List<Product>> searchProducts(
      String restaurantId, String searchText) async {
    searchIsComplete.value = false;
    final products = await _service.searchProducts(
      restaurantId,
      searchText,
    );
    searchIsComplete.value = true;
    return products;
  }

  Future<List<Product>> searchProductsByMenuId(
      String restaurantId, String menuId) async {
    searchIsComplete.value = false;
    final products = await _service.searchProductsByMenuId(
      restaurantId,
      menuId,
    );
    searchIsComplete.value = true;
    return products;
  }
}
