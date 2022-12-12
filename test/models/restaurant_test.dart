import 'package:flutter_test/flutter_test.dart';
import 'package:project1/common/models/restaurant.dart';

void main() {
  group('from Map', () {
    test('with an empty map data', () {
      final restaurant = Restaurant.fromMap('mockId', {});
      expect(
        restaurant,
        Restaurant(
          id: 'mockId',
          restaurantName: '',
          ownerName: '',
          logo: '',
          landingImage: '',
          email: '',
        ),
      );
    });
    test('with an non existing json field', () {
      final restaurant = Restaurant.fromMap('mockId', {'nonExistingField': ''});

      expect(
          restaurant,
          Restaurant(
            id: 'mockId',
            restaurantName: '',
            ownerName: '',
            logo: '',
            landingImage: '',
            email: '',
          ));
    });

    test('with all the properties', () {
      final restaurant = Restaurant.fromMap('mockId', {
        'restaurantName': 'veinte',
        'ownerName': 'mockUser',
        'logo': 'img.png',
        'email': 'test@test.abc',
      });

      expect(
          restaurant,
          Restaurant(
            id: 'mockId',
            restaurantName: 'veinte',
            ownerName: 'mockUser',
            logo: 'img.png',
            landingImage: '',
            email: 'test@test.abc',
          ));
    });

    test('missing a property', () {
      final restaurant = Restaurant.fromMap('mockId', {
        'ownerName': 'mockUser',
        'logo': 'img.png',
        'email': 'test@test.abc',
      });

      expect(
          restaurant,
          Restaurant(
            id: 'mockId',
            restaurantName: '',
            ownerName: 'mockUser',
            logo: 'img.png',
            landingImage: '',
            email: 'test@test.abc',
          ));
    });
  });

  group('toMap', () {
    test(
      'restaurant with all the properties',
      (() {
        final restaurant = Restaurant(
          id: 'mockId',
          restaurantName: 'veinte',
          ownerName: 'mockUser',
          logo: 'img.png',
          landingImage: '',
          email: 'test@test.abc',
        );

        expect(restaurant.toMap(), {
          'restaurantName': 'veinte',
          'ownerName': 'mockUser',
          'logo': 'img.png',
          'email': 'test@test.abc',
          'shortUrl': 'veinte'
        });
      }),
    );
  });
}
