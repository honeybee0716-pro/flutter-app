import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/guest.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/services/landing_service.dart';

class TableLayoutBloc {
  ValueNotifier<bool> loading = ValueNotifier(false);
  final CloudFirestoreService _dbService;
  final storage = FirebaseStorage.instance;
  late FirebaseUser userSession;

  TableLayoutBloc(FirebaseUser user) : _dbService = CloudFirestoreService() {
    userSession = user;
  }

  Future<void> addProduct(Product product, File? image) async {
    if (image != null) {
      loading.value = true;
      final imageUrl = await _saveImageToFirestorage(
        file: image,
        folderName: 'products',
        productName: product.name,
      );

      // Place the product at the end of the new category
      var productsOfNewCategory =
          await getProductsByCategory(product.categoryId);
      product.positionInCategory = productsOfNewCategory.length;

      if (imageUrl.isNotEmpty) {
        product.image = imageUrl;
        await _dbService.create('products', product);
      }
      loading.value = false;
    }
  }

  Future<void> updateProduct(Product product, File? image) async {
    loading.value = true;
    if (image != null) {
      final imageUrl = await _saveImageToFirestorage(
        file: image,
        folderName: 'products',
        productName: product.name,
      );
      if (imageUrl.isNotEmpty) {
        product.image = imageUrl;
      }
    }

    // Check current category of product
    var storedProduct = await _dbService.getProductById(product.id);

    if (product.categoryId != storedProduct.categoryId) {
      // Place the product at the end of the new category
      var productsOfNewCategory =
          await getProductsByCategory(product.categoryId);
      product.positionInCategory = productsOfNewCategory.length;
    }

    await _dbService.update(
      collectionName: 'products',
      data: product.toMap(),
      id: product.id,
    );
    loading.value = false;
  }

  Future<void> updateGuest(Guest product) async {
    loading.value = true;
    await _dbService.update(
      collectionName: 'guests',
      data: product.toMap(),
      id: product.id,
    );
    loading.value = false;
  }

  Future<void> addCategory(ProductCategory category) async {
    loading.value = true;
    await _dbService.create('categories', category);
    loading.value = false;
  }

  Future<void> updateCategory(ProductCategory category, String? menuId) async {
    loading.value = true;

    await _dbService.update(
      collectionName: 'categories',
      data: category.toMap(),
      id: category.id,
    );
    // (Roberto) This helps to update the menuId of the products that belong to this category
    // when the category is updated in a bulk update.
    if (menuId != null) {
      final productsByCategory = await _dbService.getProductsByCategoryId(
        userSession.uid,
        category.id,
      );
      for (final product in productsByCategory) {
        product.menuId = menuId;
        await _dbService.update(
          collectionName: 'products',
          data: product.toMap(),
          id: product.id,
        );
      }
    }
    loading.value = false;
  }

  Future<void> addMenu(Menu menu) async {
    loading.value = true;
    await _dbService.create('menus', menu);
    loading.value = false;
  }

  Future<void> updateMenu(Menu menu) async {
    loading.value = true;

    await _dbService.update(
      collectionName: 'menus',
      data: menu.toMap(),
      id: menu.id,
    );
    loading.value = false;
  }

  Future<void> softDeleteProduct(Product product) async {
    loading.value = true;
    _dbService.update(
      collectionName: 'products',
      data: product.toMap(),
      id: product.id,
    );
    loading.value = false;
  }

  Future<void> deleteProfile() async {
    loading.value = true;
    _dbService.delete(
      collectionName: 'restaurants',
      documentId: userSession.uid,
    );
    loading.value = false;
  }

  Future<void> deleteProduct(String productId) async {
    loading.value = true;
    _dbService.delete(collectionName: 'products', documentId: productId);
    loading.value = false;
  }

  Future<void> deleteCategory(String categoryId) async {
    loading.value = true;
    _dbService.delete(collectionName: 'categories', documentId: categoryId);
    loading.value = false;
  }

  Future<bool> changeProductStatus(Product product) async {
    loading.value = true;
    product.enabled = !product.enabled;
    await _dbService.update(
      collectionName: 'products',
      data: product.toMap(),
      id: product.id,
    );
    loading.value = false;
    return true;
  }

  Future<bool> updateProducts(List<Product> products) async {
    await _dbService.updateMany(
        collectionName: 'products',
        updateDtos: products.map((e) => UpdateDto(e.id, e.toMap())).toList());

    return true;
  }

  Future<List<Menu>> getMenusByRestaurantId() {
    return _dbService.getMenus(userSession.uid);
  }

  Stream<List<ProductCategory>> streamCategories() {
    return _dbService.streamCategories(userSession.uid);
  }

  Stream<List<Product>> streamProductByCategory(String categoryId) {
    return _dbService.streamProductByCategory(categoryId);
  }

  Future<List<Product>> getProductsByCategory(String categoryId) {
    return _dbService.getProductsByCategory(categoryId);
  }

  Stream<List<Product>> streamDeletedProducts() {
    return _dbService.streamDeletedProducts(userSession.uid);
  }

  Stream<List<Guest>> streamRestaurantGuests() {
    return _dbService.streamGuests(userSession.uid);
  }

  Stream<Guest> streamGuestById(String guestId) {
    return _dbService.streamGuestById(guestId);
  }

  Future<List<Product>> searchProducts(
      String restaurantId, String searchText) async {
    final products = await _dbService.searchProducts(
      restaurantId,
      searchText,
      isPanelAdmin: true,
    );
    return products;
  }

  Future<String> _saveImageToFirestorage({
    required File file,
    required String folderName,
    required String productName,
  }) async {
    String downloadUrl = '';

    final mountainImagesRef =
        storage.ref().child("$folderName/$productName.jpg");
    try {
      await mountainImagesRef.putFile(file);
      downloadUrl = await mountainImagesRef.getDownloadURL();
    } catch (e) {
      rethrow;
    }

    return downloadUrl;
  }
}
