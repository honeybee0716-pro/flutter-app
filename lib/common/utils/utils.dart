import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> hasAlreadySetupLogo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // SETUP means if the user already
  // upload the restaurant logo for the
  // first time.
  return prefs.getBool("setup") ?? false;
}

String? validateEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value) && value.isNotEmpty) {
    return 'Enter a valid email';
  } else if (value.isEmpty) {
    return 'The field is required';
  } else {
    return null;
  }
}

void navigateToPushReplace(BuildContext context, Widget nextPage) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return OpenContainer(
          transitionType: ContainerTransitionType.fade,
          openBuilder: (BuildContext context, VoidCallback _) {
            return nextPage;
          },
          tappable: false,
          closedBuilder: (BuildContext _, VoidCallback openContainer) {
            return nextPage;
          },
        );
      },
    ),
  );
}

Future<File?> pickImage() async {
  final image = await ImagePicker()
      .pickImage(source: ImageSource.gallery, imageQuality: 50);
  if (image == null) return null;
  final imageTemporary = File(image.path);
  return imageTemporary;
}
