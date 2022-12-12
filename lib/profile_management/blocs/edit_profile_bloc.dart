import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/services/landing_service.dart';

class EditProfileBloc {
  ValueNotifier<bool> loading = ValueNotifier(false);
  final CloudFirestoreService _service;
  final storage = FirebaseStorage.instance;

  EditProfileBloc() : _service = CloudFirestoreService();

  Future<Restaurant> getRestaurantProfile(String id) async {
    return await _service.getRestaurantById(id);
  }

  Future<void> updateRestaurantProfile(
      Restaurant restaurant, File? logo) async {
    loading.value = true;

    if (logo != null) {
      restaurant.logo = await _uploadRestaurantLogo(
        logo,
        restaurant.restaurantName,
        'logo',
      );
    }
    await _service.update(
        collectionName: 'restaurants',
        data: restaurant.toMap(),
        id: restaurant.id);
    loading.value = false;
  }

  Future<void> updateLandingRestaurantInformation(
      Restaurant restaurant, File? landingImage) async {
    loading.value = true;

    if (landingImage != null) {
      restaurant.landingImage = await _uploadRestaurantLogo(
          landingImage, restaurant.restaurantName, 'landing');
    }
    await _service.update(
      collectionName: 'restaurants',
      data: restaurant.toMap(),
      id: restaurant.id,
    );
    loading.value = false;
  }

  Future<String> _uploadRestaurantLogo(
      File logo, String restaurantName, String imageType) async {
    // imageType = 'logo' or 'landing'
    final restaurantLogoUrl = await _saveRestaurantLogoToFirestorage(
      file: logo,
      restaurantName: restaurantName,
      imageType: imageType,
    );

    return restaurantLogoUrl;
  }

  Future<String> _saveRestaurantLogoToFirestorage(
      {required File file,
      required String restaurantName,
      required String imageType}) async {
    String downloadUrl = '';

    final mountainImagesRef =
        storage.ref().child("restaurants/$restaurantName-$imageType.jpg");
    try {
      await mountainImagesRef.putFile(file);
      downloadUrl = await mountainImagesRef.getDownloadURL();
    } catch (e) {
      rethrow;
    }

    return downloadUrl;
  }
}
