import 'dart:core';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/custom_loader.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/pinput_widget.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/sign_in_name_screen.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/sign_in_page_main_layout.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    Key? key,
    required this.restaurant,
    required this.phoneNumber,
  }) : super(key: key);

  final Restaurant restaurant;

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with WidgetsBindingObserver {
  final pinputFocusNode = FocusNode();

  bool isKeyboardVisible = false;

  late final ScrollController scrollController;
  late AuthenticationBLoc bloc = context.read<AuthenticationBLoc>();

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(pinputFocusNode);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomViewInsets = WidgetsBinding.instance.window.viewInsets.bottom;
    isKeyboardVisible = bottomViewInsets > 0;
  }

  @override
  Widget build(BuildContext context) {
    final content = FirebasePhoneAuthHandler(
      phoneNumber: widget.phoneNumber,
      signOutOnSuccessfulVerification: false,
      linkWithExistingUser: false,
      autoRetrievalTimeOutDuration: const Duration(seconds: 60),
      otpExpirationDuration: const Duration(seconds: 60),
      onCodeSent: () {
        //print('OTP sent!');
      },
      onLoginSuccess: (userCredential, autoVerified) async {
        debugPrint("autoVerified: $autoVerified");
        debugPrint("Login success UID: ${userCredential.user?.uid}");
        showInfoSnackBar('Phone number verified successfully!');

        final isNewUser = userCredential.additionalUserInfo?.isNewUser;

        // If user is new or has no display name, move to Name page
        if (isNewUser == true ||
            userCredential.user?.displayName == null ||
            userCredential.user?.displayName == 'No name') {
          GoRouter.of(context).push(
              '/${widget.restaurant.shortUrl}/signin/phone/name',
              extra: SignInNameScreenArguments(
                  restaurant: widget.restaurant, user: userCredential.user!));
        } else {
          // Move to menu page after logging the last visit field
          await bloc.registerOrUpdatePhoneGuest(
            id: userCredential.user!.uid,
            name: userCredential.user!.displayName!,
            phoneNumber: userCredential.user!.phoneNumber!,
            restaurantId: widget.restaurant.toFirebaseUser().uid,
          );
          GoRouter.of(context).push('/${widget.restaurant.shortUrl}/menu',
              extra: {"user": widget.restaurant.toFirebaseUser()});
        }
      },
      onLoginFailed: (authException, stackTrace) {
        debugPrint("An error occurred: ${authException.message}");

        showErrorSnackBar('Login failed');

        switch (authException.code) {
          case 'invalid-phone-number':
            // invalid phone number
            return showErrorSnackBar('Invalid phone number!');
          case 'invalid-verification-code':
            // invalid otp entered
            return showErrorSnackBar('The entered OTP is invalid!');
          // handle other error codes
          default:
            showErrorSnackBar('Something went wrong!');
          // handle error further if needed
        }
      },
      onError: (error, stackTrace) {
        showErrorSnackBar('An error occurred!');
      },
      builder: (context, controller) {
        return Container(
          child: controller.isSendingCode
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CustomLoader(color: Colors.white),
                    SizedBox(height: 50),
                    Center(
                      child: Text(
                        'Sending OTP',
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    if (controller.codeSent)
                      TextButton(
                        onPressed: controller.isOtpExpired
                            ? () async {
                                debugPrint('Resend OTP');
                                await controller.sendOTP();
                              }
                            : null,
                        child: Text(
                          controller.isOtpExpired
                              ? 'Resend'
                              : '${controller.otpExpirationTimeLeft.inSeconds}s',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ),
                    const SizedBox(width: 5),
                    Text(
                      "We've sent an SMS \nwith a verification code \nto ${widget.phoneNumber}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 15),
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    PinputWidget(
                      onCompleted: controller.verifyOtp,
                      focusNode: pinputFocusNode,
                    ),
                  ],
                ),
        );
      },
    );
    return SignInPageMainLayout(
      restaurant: widget.restaurant,
      columnChildren: [content],
    );
  }

  void showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg, style: TextStyle(color: Colors.white))));
  }

  void showInfoSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        content: Text(msg, style: TextStyle(color: Colors.white))));
  }
}
