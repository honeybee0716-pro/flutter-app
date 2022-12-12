import 'package:flutter/material.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/authentication/pages/login_screen.dart';
import 'package:project1/authentication/pages/upload_logo_screen.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/pages/home_screen.dart';
import 'package:provider/provider.dart';

class RouteScreen extends StatelessWidget {
  const RouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticationBloc = context.read<AuthenticationBLoc>();
    return StreamBuilder<FirebaseUser?>(
      stream: authenticationBloc.onAuthStateChanged,
      builder: (_, AsyncSnapshot<FirebaseUser?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final FirebaseUser? user = snapshot.data;
          if (user == null || user.uid.isEmpty) {
            return Provider.value(
              value: authenticationBloc,
              child: const LoginScreen(),
            );
          }
          return buildLandingScreen(
            user,
            authenticationBloc,
          );
        } else {
          return buildLoading();
        }
      },
    );
  }

  Widget buildLoading() {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildLandingScreen(
      FirebaseUser user, AuthenticationBLoc authenticationBloc) {
    return FutureBuilder<bool>(
      future: authenticationBloc.initializeRestaurant(user.uid),
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null) {
          return buildLoading();
        }

        final currentLogo = authenticationBloc.currentRestaurant?.logo ?? '';
        return ValueListenableBuilder(
          valueListenable: authenticationBloc.skipToUploadLogo,
          builder: (context, bool skipToUploadLogo, _) {
            return Provider.value(
              value: user,
              child: currentLogo.isNotEmpty || skipToUploadLogo
                  ? HomeScreen(
                      firebaseUser: user,
                      shortUrl: authenticationBloc.currentRestaurant!.shortUrl!)
                  : Provider.value(
                      value: authenticationBloc,
                      child: const UploadLogoScreen(),
                    ),
            );
          },
        );
      },
    );
  }
}
