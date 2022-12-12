import 'package:flutter/material.dart';
import 'package:project1/authentication/pages/web/guest_sign_in_screen.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/services/landing_service.dart';
import 'package:provider/provider.dart';

class WebRouterScreen extends StatelessWidget {
  const WebRouterScreen({
    Key? key,
    required this.shortUrl,
  }) : super(key: key);

  final String shortUrl;

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
        return Provider.value(
          value: FirebaseUser(
              uid: restaurantData.id,
              email: restaurantData.email,
              isVerified: true,
              providerId: ''),
          child: GuestSignInScreen(shortUrl: shortUrl),
        );
      },
    );
  }
}
