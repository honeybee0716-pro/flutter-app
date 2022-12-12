import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/blocs/home_bloc.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/profile_management/pages/edit_profile_screen.dart';
import 'package:provider/provider.dart';

class RestaurantLogo extends StatefulWidget {
  const RestaurantLogo({
    Key? key,
    required this.backgroundColor,
  }) : super(key: key);

  final Color backgroundColor;

  @override
  State<RestaurantLogo> createState() => _RestaurantLogoState();
}

class _RestaurantLogoState extends State<RestaurantLogo> {
  late final userSession = context.read<FirebaseUser>();
  late final homeBloc = context.read<HomeBloc>();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: GestureDetector(
        onTap: () async {
          // Manage edit logo.
          if (!kIsWeb) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Provider.value(
                  value: userSession,
                  child: const EditProfileScreen(),
                ),
              ),
            );
            setState(() {});
          }
        },
        child: FutureBuilder<Restaurant>(
          future: homeBloc.getRestaurantById(userSession.uid),
          builder: (context, snapshot) {
            final restaurant = snapshot.data;
            if (restaurant == null) {
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            }
            if (restaurant.logo.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'YOUR LOGO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              );
            }
            return Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kIsWeb ? 100 : 80),
                child: kIsWeb
                    ? Image.network(
                        restaurant.logo,
                        width: 180,
                        height: 180,
                      )
                    : CachedNetworkImage(
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        imageUrl: restaurant.logo,
                        errorWidget: (context, url, error) {
                          return Center(
                            child: Text(
                              error.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        },
                        placeholder: (context, url) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
