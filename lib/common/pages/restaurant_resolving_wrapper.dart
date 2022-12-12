import 'package:flutter/material.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/services/landing_service.dart';
import 'package:provider/provider.dart';

// This widget resolves the restaurant and passes the respective user to the child screen.
// In case the restaurant is not found, it returns the appropriate NotFound message.
class RestaurantResolvingWrapper extends StatelessWidget {
  const RestaurantResolvingWrapper(
      {Key? key, required this.shortUrl, required this.widgedProvider})
      : super(key: key);

  final String shortUrl;
  final Widget Function(FirebaseUser user, Restaurant restaurant)
      widgedProvider;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant>(
      future: context
          .read<CloudFirestoreService>()
          .getRestaurantByShortUrl(shortUrl),
      builder: (context, snapshot) {
        final restaurantData = snapshot.data;
        if (restaurantData == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        if (restaurantData.id == 'notFound') {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo-2.png',
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Verify your url, it seems like it is not found!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return widgedProvider(
            FirebaseUser(
                uid: restaurantData.id,
                email: restaurantData.email,
                isVerified: true,
                providerId: ''),
            restaurantData);
      },
    );
  }
}
