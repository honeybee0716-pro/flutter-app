import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/guest.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/mynuu_model.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/restaurant.dart';

class CloudFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ProductCategory>> streamCategories(
    String restaurantId, {
    int? limit,
  }) {
    var ref = _db.collection('categories').where(
          'restaurantId',
          isEqualTo: restaurantId,
        );
    if (limit != null) {
      ref = ref.limit(limit);
    }
    return ref.snapshots().map(
          (list) => list.docs
              .map(
                (doc) => ProductCategory.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Menu>> getMenus(String restaurantId) async {
    var ref = _db.collection('menus').where(
          'restaurantId',
          isEqualTo: restaurantId,
        );

    return ref.get().then(
          (value) => value.docs
              .map(
                (doc) => Menu.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<ProductCategory>> getCategories(String restaurantId) async {
    var ref = _db.collection('categories').where(
          'restaurantId',
          isEqualTo: restaurantId,
        );

    return ref.get().then(
          (value) => value.docs
              .map(
                (doc) => ProductCategory.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Product>> getProductsByCategory(String categoryId) {
    //add two values userID and string global
    var ref = _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('deleted', isEqualTo: false);

    return ref.get().then(
          (value) => value.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Product>> streamProductByCategory(String categoryId) {
    //add two values userID and string global
    var ref = _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('deleted', isEqualTo: false);

    return ref.snapshots().map(
          (list) => list.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Product>> streamEnabledProductByCategory(String categoryId) {
    //add two values userID and string global
    var ref = _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .where('enabled', isEqualTo: true)
        .where('deleted', isEqualTo: false);

    return ref.snapshots().map(
          (list) => list.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Product>> streamDeletedProducts(String restaurantId) {
    //add two values userID and string global
    var ref = _db
        .collection('products')
        .where(
          'deleted',
          isEqualTo: true,
        )
        .where(
          'restaurantId',
          isEqualTo: restaurantId,
        );

    return ref.snapshots().map(
          (list) => list.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Guest>> streamGuests(String restaurantId) {
    //add two values userID and string global
    var ref = _db.collection('guests').where(
          'restaurantId',
          isEqualTo: restaurantId,
        );

    return ref.snapshots().map(
          (list) => list.docs
              .map(
                (doc) => Guest.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Product>> searchProducts(
    String restaurantId,
    String searchText, {
    bool isPanelAdmin = false,
  }) async {
    searchText = searchText.toLowerCase();
    final strFrontCode = searchText.substring(0, searchText.length - 1);
    final strEndCode = searchText.characters.last;
    final limit =
        strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);

    var ref = _db
        .collection('products')
        .where('deleted', isEqualTo: false)
        .where('restaurantId', isEqualTo: restaurantId)
        .where("keyword", isGreaterThanOrEqualTo: searchText)
        .where("keyword", isLessThan: limit);

    if (!isPanelAdmin) {
      ref = ref.where('enabled', isEqualTo: true);
    }

    return ref.get().then(
          (value) => value.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Product>> searchProductsByMenuId(
    String restaurantId,
    String menuId, {
    bool isPanelAdmin = false,
  }) async {
    var ref = _db
        .collection('products')
        .where('deleted', isEqualTo: false)
        .where('restaurantId', isEqualTo: restaurantId)
        .where("menuId", isEqualTo: menuId);

    if (!isPanelAdmin) {
      ref = ref.where('enabled', isEqualTo: true);
    }

    return ref.get().then(
          (value) => value.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Product>> getProductsByCategoryId(
    String restaurantId,
    String categoryId,
  ) async {
    var ref = _db
        .collection('products')
        .where('restaurantId', isEqualTo: restaurantId)
        .where("categoryId", isEqualTo: categoryId);

    return ref.get().then(
          (value) => value.docs
              .map(
                (doc) => Product.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<Product> getProductById(String id) async {
    return _db.collection('products').doc(id).get().then(
          (snap) => Product.fromMap(
            snap.id,
            snap.data() ?? {},
          ),
        );
  }

  Future<Restaurant> getRestaurantByShortUrl(String name) async {
    final restaurants = await _db
        .collection('restaurants')
        .where('shortUrl', isEqualTo: name)
        .limit(1)
        .get()
        .then(
          (snap) => snap.docs
              .map(
                (restaurant) => Restaurant.fromMap(
                  restaurant.id,
                  restaurant.data(),
                ),
              )
              .toList(),
        );
    if (restaurants.isEmpty) {
      return Restaurant.notFound();
    }

    return restaurants.first;
  }

  Future<Restaurant> getRestaurantById(String id) async {
    var request = _db.collection('restaurants').doc(id).get();
    return request.then(
      (snap) => Restaurant.fromMap(
        snap.id,
        snap.data() ?? {},
      ),
    );
  }

  Stream<Restaurant> streamRestaurantById(String id) {
    return _db.collection('restaurants').doc(id).snapshots().map(
          (snap) => Restaurant.fromMap(
            snap.id,
            snap.data() ?? {},
          ),
        );
  }

  Stream<Guest> streamGuestById(String id) {
    return _db.collection('guests').doc(id).snapshots().map(
          (snap) => Guest.fromMap(
            snap.id,
            snap.data() ?? {},
          ),
        );
  }

  Future<Guest> getGuestById(String id) async {
    return _db.collection('guests').doc(id).get().then(
          // this can be null if the guest is not found
          // ignore: unnecessary_null_comparison
          (snap) => Guest.fromMap(
            snap.id,
            snap.data() ?? {},
          ),
        );
  }

  Future<void> create(String collectionName, MynuuModel object) async {
    _db.collection(collectionName).add(
          object.toMap(),
        );
  }

  Future<void> createWithId(
      String collectionName, String id, MynuuModel object) async {
    _db.collection(collectionName).doc(id).set(
          object.toMap(),
        );
  }

  Future<void> update({
    required String collectionName,
    required Map<String, dynamic> data,
    required String id,
  }) async {
    var ref = _db.collection(collectionName);
    await ref.doc(id).update(data);
    return;
  }

  Future<void> updateMany(
      {required String collectionName,
      required List<UpdateDto> updateDtos}) async {
    final batch = _db.batch();

    for (var item in updateDtos) {
      batch.update(_db.collection(collectionName).doc(item.id), item.data);
    }
    await batch.commit();

    return;
  }

  Future<void> delete({
    required String collectionName,
    required String documentId,
  }) async {
    return _db
        .collection(
          collectionName,
        )
        .doc(documentId)
        .delete();
  }
}

class UpdateDto {
  final Map<String, dynamic> data;
  final String id;

  UpdateDto(this.id, this.data);
}
