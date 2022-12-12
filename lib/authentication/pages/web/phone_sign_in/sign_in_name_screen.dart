import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/authentication/components/custom_textfield.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/custom_loader.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/sign_in_button.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/sign_in_page_main_layout.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:provider/provider.dart';

class SignInNameScreen extends StatefulWidget {
  const SignInNameScreen({Key? key, required this.restaurant, this.user})
      : super(key: key);

  final Restaurant restaurant;
  final User? user;

  @override
  State<SignInNameScreen> createState() => _SignInNameScreenState();
}

class _SignInNameScreenState extends State<SignInNameScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();

  late AuthenticationBLoc bloc = context.read<AuthenticationBLoc>();

  bool loading = false;

  DateTime? birthdate;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const CustomLoader();
    }

    return SignInPageMainLayout(restaurant: widget.restaurant, columnChildren: [
      AutofillGroup(
        child: CustomTextField(
            autofillHints: const [AutofillHints.name],
            backgroundColor: Colors.white,
            enabledBorderColor: Colors.black,
            textColor: Colors.black,
            hintText: 'Name',
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Colors.black,
            ),
            controller: nameController),
      ),
      if (widget.restaurant.askForBirthDate)
        const SizedBox(
          height: 15,
        ),
      if (widget.restaurant.askForBirthDate)
        CustomTextField(
            backgroundColor: Colors.white,
            enabledBorderColor: Colors.black,
            textColor: Colors.black,
            readOnly: true,
            hintText: 'Birthday',
            prefixIcon: const Icon(
              Icons.calendar_today,
              color: Colors.black,
            ),
            controller: birthdateController,
            onClick: () async {
              birthdate = await DatePicker.showSimpleDatePicker(context,
                  initialDate: DateTime(1994),
                  firstDate: DateTime(1960),
                  lastDate: DateTime(2014),
                  dateFormat: "MMMM-dd",
                  locale: DateTimePickerLocale.en_us,
                  looping: true,
                  backgroundColor: Colors.black,
                  textColor: Colors.white);

              if (birthdate != null) {
                birthdateController.text =
                    DateFormat('MMMM dd').format(birthdate!);
                setState(() {});
              }
            }),
      const SizedBox(height: 50),
      SignInButton(
          label: 'Next',
          onTap: () async {
            return _signInGuestWithName(
                widget.user, nameController.text, birthdate, widget.restaurant);
          })
    ]);
  }

  Future<void> _signInGuestWithName(User? firebaseUser, String name,
      DateTime? birthdate, Restaurant restaurant) async {
    setState(() {
      loading = true;
    });

    try {
      // Update user's DisplayName
      await firebaseUser!.updateDisplayName(name);
      final restaurantFirebaseUser = restaurant.toFirebaseUser();

      // Register guest
      await bloc.registerOrUpdatePhoneGuest(
        id: firebaseUser.uid,
        name: name,
        birthdate: birthdate,
        phoneNumber: firebaseUser.phoneNumber!,
        restaurantId: restaurantFirebaseUser.uid,
      );
      _goToNextPage(restaurantFirebaseUser);
    } on PlatformException catch (e) {
      await _showSignInError(context, e.message);
    } catch (e) {
      setState(() {
        loading = false;
      });
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
        .push('/${widget.restaurant.shortUrl}/menu', extra: {"user": user});
  }
}

class SignInNameScreenArguments {
  final Restaurant restaurant;
  final User user;

  SignInNameScreenArguments({required this.restaurant, required this.user});
}
