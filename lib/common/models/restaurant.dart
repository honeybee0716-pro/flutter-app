import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project1/common/models/mynuu_model.dart';
import 'package:project1/common/models/user_system.dart';

class Restaurant implements MynuuModel {
  final String id;
  String restaurantName;
  final String ownerName;
  String logo;
  String landingImage;
  final String email;
  String? shortUrl;

  bool isFacebookEnabled;

  bool askForBirthDate;

  bool isGoogleEnabled;

  bool isPhoneLoginEnabled;

  bool isAnonymousLoginEnabled;

  Color guestCheckInColor;

  String? pushNotificationToken;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.ownerName,
    required this.logo,
    required this.landingImage,
    required this.email,
    this.shortUrl,
    this.isFacebookEnabled = false,
    this.isGoogleEnabled = false,
    this.isPhoneLoginEnabled = false,
    this.isAnonymousLoginEnabled = false,
    this.askForBirthDate = false,
    this.guestCheckInColor = Colors.black,
    this.pushNotificationToken,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'restaurantName': restaurantName,
      'ownerName': ownerName,
      'logo': logo,
      'landingImage': landingImage,
      'email': email,
      'shortUrl': _getshortRestaurantUrl(),
      'isFacebookEnabled': isFacebookEnabled,
      'isGoogleEnabled': isGoogleEnabled,
      'isPhoneLoginEnabled': isPhoneLoginEnabled,
      'isAnonymousLoginEnabled': isAnonymousLoginEnabled,
      'askForBirthDate': askForBirthDate,
      'guestCheckInColor': toHex(leadingHashSign: false),
      'pushNotificationToken': pushNotificationToken,
    };
  }

  // get empty restaurant
  factory Restaurant.empty() {
    return Restaurant(
      id: '',
      restaurantName: '',
      ownerName: '',
      logo: '',
      landingImage: '',
      email: '',
    );
  }

  factory Restaurant.notFound() {
    return Restaurant(
      id: 'notFound',
      restaurantName: 'notFound',
      ownerName: 'notFound',
      logo: '',
      landingImage: '',
      email: 'notFound',
    );
  }

  factory Restaurant.fromMap(String id, Map<String, dynamic> map) {
    final restaurantThemeColor = map['guestCheckInColor'] ?? '#000000';
    return Restaurant(
      id: id,
      restaurantName: map['restaurantName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      logo: map['logo'] ?? '',
      landingImage: map['landingImage'] ?? '',
      email: map['email'] ?? '',
      shortUrl: map['shortUrl'] ?? '',
      isFacebookEnabled: map['isFacebookEnabled'] ?? false,
      isGoogleEnabled: map['isGoogleEnabled'] ?? false,
      isPhoneLoginEnabled: map['isPhoneLoginEnabled'] ?? false,
      isAnonymousLoginEnabled: map['isAnonymousLoginEnabled'] ?? false,
      askForBirthDate: map['askForBirthDate'] ?? false,
      guestCheckInColor: Color(
        int.parse(restaurantThemeColor.replaceAll("#", ""), radix: 16),
      ),
      pushNotificationToken: map['pushNotificationToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Restaurant.fromJson(String id, String source) => Restaurant.fromMap(
        id,
        json.decode(source),
      );

  String _getshortRestaurantUrl() {
    String restaurantName = this.restaurantName;
    return restaurantName.toLowerCase().replaceAll(' ', '-');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Restaurant &&
        other.id == id &&
        other.restaurantName == restaurantName &&
        other.ownerName == ownerName &&
        other.logo == logo &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        restaurantName.hashCode ^
        ownerName.hashCode ^
        logo.hashCode ^
        email.hashCode;
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, restaurantName: $restaurantName, ownerName: $ownerName, logo: $logo, email: $email, shortUrl: $shortUrl)';
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${guestCheckInColor.alpha.toRadixString(16).padLeft(2, '0')}'
      '${guestCheckInColor.red.toRadixString(16).padLeft(2, '0')}'
      '${guestCheckInColor.green.toRadixString(16).padLeft(2, '0')}'
      '${guestCheckInColor.blue.toRadixString(16).padLeft(2, '0')}';

  FirebaseUser toFirebaseUser() {
    return FirebaseUser(
        uid: id, email: email, isVerified: true, providerId: '');
  }
}
