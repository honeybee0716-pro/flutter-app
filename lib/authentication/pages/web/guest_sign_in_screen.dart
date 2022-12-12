import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class GuestSignInScreen extends StatefulWidget {
  const GuestSignInScreen({Key? key, required this.shortUrl}) : super(key: key);

  final String shortUrl;

  @override
  State<GuestSignInScreen> createState() => _GuestSignInScreenState();
}

class _GuestSignInScreenState extends State<GuestSignInScreen> {
  late AuthenticationBLoc bloc = context.read<AuthenticationBLoc>();
  @override
  Widget build(BuildContext context) {
    const loginButtonsWidth = double.infinity;

    final userSession = context.read<FirebaseUser>();
    return StreamBuilder<Restaurant>(
      stream: bloc.streamRestaurantById(userSession.uid),
      builder: (context, snapshot) {
        final restaurant = snapshot.data;
        if (restaurant == null) {
          return Scaffold(
            body: Column(
              children: const [
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              if (restaurant.landingImage.isNotEmpty)
                Image.network(
                  restaurant.landingImage,
                  fit: BoxFit.cover,
                  height: 100.h,
                  width: 100.w,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (restaurant.isAnonymousLoginEnabled)
                      _createSignInButton(loginButtonsWidth, context),
                    if (restaurant.isAnonymousLoginEnabled)
                      const SizedBox(
                        height: 30,
                      ),
                    if (restaurant.isPhoneLoginEnabled)
                      _createPhoneSignInButton(loginButtonsWidth, context),
                    const SizedBox(
                      height: 70,
                    ),
                    if (restaurant.isFacebookEnabled)
                      _createSocialLoginButton(
                        context,
                        loginButtonsWidth: loginButtonsWidth,
                        iconPath: 'assets/facebook.png',
                        buttonText: 'Continue with Facebook',
                        textColor: Colors.white,
                        backgroundColor: const Color(0xFF1877F2),
                        onTap: () {
                          _signInWith(context, google: false);
                        },
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (restaurant.isGoogleEnabled)
                      _createSocialLoginButton(
                        context,
                        loginButtonsWidth: loginButtonsWidth,
                        iconPath: 'assets/google.png',
                        buttonText: 'Continue with Google',
                        textColor: Colors.grey.shade700,
                        backgroundColor: Colors.white,
                        onTap: () {
                          _signInWith(context, google: true);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SizedBox _createSocialLoginButton(BuildContext context,
      {required double loginButtonsWidth,
      required String iconPath,
      required String buttonText,
      required Color textColor,
      required VoidCallback? onTap,
      required Color backgroundColor}) {
    return SizedBox(
      height: 50,
      width: loginButtonsWidth,
      child: OutlinedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: onTap,
        icon: Image.asset(
          iconPath,
          width: 23,
          filterQuality: FilterQuality.high,
        ),
        label: Text(
          buttonText,
          style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              color: textColor,
              fontSize: 20),

          // TextStyle(color: textColor, fontSize: 20),
        ),
      ),
    );
  }

  SizedBox _createSignInButton(double loginButtonsWidth, BuildContext context) {
    return SizedBox(
      height: 50,
      width: loginButtonsWidth,
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.white,
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () {
          _goToNextPage(context.read<FirebaseUser>());
        },
        child: Text(
          'Tap to start',
          style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 20),
        ),
      ),
    );
  }

  SizedBox _createPhoneSignInButton(
      double loginButtonsWidth, BuildContext context) {
    return SizedBox(
      height: 50,
      width: loginButtonsWidth,
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.white,
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () {
          GoRouter.of(context).push('/${widget.shortUrl}/signin/phone');
        },
        child: Text(
          'Sign in with phone number',
          style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 20),
        ),
      ),
    );
  }

  Future<void> _signInWith(BuildContext context, {bool google = true}) async {
    try {
      final user = google
          ? await bloc.signInWithGoogle()
          : await bloc.signInWithFacebook();
      final restaurantFirebaseUser = context.read<FirebaseUser>();

      await bloc.registerGuest(
        id: user.uid,
        email: user.email,
        name: user.displayName ?? 'No name',
        restaurantId: restaurantFirebaseUser.uid,
        signInType: google ? 'google' : 'facebook',
      );
      _goToNextPage(restaurantFirebaseUser);
    } on PlatformException catch (e) {
      await _showSignInError(context, e.message);
    } catch (e) {
      await _showSignInError(
        context,
        e.toString(),
      );
    }
  }

  Future<void> _showSignInError(BuildContext context, String? message) async {
    await PlatformAlertDialog(
            content: message?.replaceAll('firebase_auth/', '') ??
                'There was an error, try it later!',
            title: 'Login failed',
            defaultActionText: 'Ok')
        .show(context);
  }

  void _goToNextPage(FirebaseUser user) {
    GoRouter.of(context)
        .push('/${widget.shortUrl}/menu', extra: {"user": user});
  }
}
