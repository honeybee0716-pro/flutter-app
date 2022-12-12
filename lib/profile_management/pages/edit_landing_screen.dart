import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/utils/utils.dart';
import 'package:project1/profile_management/blocs/edit_profile_bloc.dart';
import 'package:provider/provider.dart';

class EditLandingScreen extends StatefulWidget {
  const EditLandingScreen({Key? key}) : super(key: key);

  @override
  State<EditLandingScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditLandingScreen> {
  final GlobalKey<FormState> editForm = GlobalKey<FormState>();
  late EditProfileBloc bloc = EditProfileBloc();

  Restaurant? initialRestaurant;
  Restaurant? updatedRestaurant;

  File? newLandingImage;

  List<Color> userColors = [
    Colors.purple,
    Colors.pinkAccent,
    Colors.blue,
    Colors.orange,
    Colors.white,
    Colors.red,
  ];
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Restaurant>(
      future: bloc.getRestaurantProfile(
        context.read<FirebaseUser>().uid,
      ),
      builder: (_, snapshot) {
        final restaurant = snapshot.data;
        if (restaurant == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
        initialRestaurant ??= restaurant;
        updatedRestaurant ??= restaurant;

        return Stack(
          children: [
            newLandingImage == null
                ? restaurant.landingImage.isEmpty
                    ? Image.asset(
                        'assets/landing.png',
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      )
                    : Image.network(
                        restaurant.landingImage,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      )
                : Image.file(
                    newLandingImage!,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: editForm,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(restaurant.restaurantName,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 30,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildEditLandingImageButton(),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSocialNetworkButton(
                              width: 50,
                              title: 'Google',
                              //    icon: 'assets/google-guest.png',
                              value: updatedRestaurant!.isGoogleEnabled,
                              onChanged: (value) {
                                setState(() {
                                  updatedRestaurant!.isGoogleEnabled = value;
                                });
                              }),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: _buildSocialNetworkButton(
                              title: 'Facebook',
                              //     icon: 'assets/facebook-guest.png',
                              value: updatedRestaurant!.isFacebookEnabled,
                              onChanged: (value) {
                                setState(() {
                                  updatedRestaurant!.isFacebookEnabled = value;
                                });
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildSocialNetworkButton(
                                title: 'Phone',
                                //     icon: 'assets/phone-icon.png',
                                value: updatedRestaurant!.isPhoneLoginEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    updatedRestaurant!.isPhoneLoginEnabled =
                                        value;
                                  });
                                })),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: _buildSocialNetworkButton(
                              title: 'Anonymous',
                              // icon: 'assets/vip.png',
                              value: updatedRestaurant!.isAnonymousLoginEnabled,
                              onChanged: (value) {
                                setState(() {
                                  updatedRestaurant!.isAnonymousLoginEnabled =
                                      value;
                                });
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildSocialNetworkButton(
                        title: 'Birthday',
                        icon: 'assets/vip.png',
                        value: updatedRestaurant!.askForBirthDate,
                        onChanged: (value) {
                          setState(() {
                            updatedRestaurant!.askForBirthDate = value;
                          });
                        }),
                    const SizedBox(
                      height: 30,
                    ),
                    const Center(
                      child: Text('Profile Themes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...userColors
                            .map(
                              (color) => buildColorDot(
                                color,
                                selectedColor:
                                    updatedRestaurant!.guestCheckInColor,
                                onTap: () {
                                  setState(
                                    () {
                                      updatedRestaurant!.guestCheckInColor =
                                          color;
                                    },
                                  );
                                },
                              ),
                            )
                            .toList(),
                        IconButton(
                          onPressed: openPickerColor,
                          icon: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSaveAction(),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildEditLandingImageButton() {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            const BorderSide(
              color: Colors.white,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
        onPressed: () async {
          newLandingImage = await pickImage();
          setState(() {});
        },
        child: const Text(
          'EDIT LANDING PAGE IMAGE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildColorDot(Color color,
      {required Color selectedColor, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: color.value == selectedColor.value
              ? const Icon(
                  Icons.check,
                  color: Colors.black,
                )
              : Container(),
        ),
      ),
    );
  }

  Widget _buildSocialNetworkButton({
    required String title,
    String? icon,
    required bool value,
    double? width,
    double? height = 55,
    required Function(bool) onChanged,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: SwitchListTile(
          contentPadding: EdgeInsets.only(left: 10, bottom: 10, right: 3),
          value: value,
          onChanged: onChanged,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Image.asset(
                    icon,
                  ),
                ),
              if (icon != null)
                const SizedBox(
                  width: 10,
                ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveAction() {
    return ValueListenableBuilder(
      valueListenable: bloc.loading,
      builder: (context, bool loading, _) {
        return ElevatedButton.icon(
          onPressed: () async {
            // save profile edit
            if (editForm.currentState!.validate()) {
              final restaurantToUpdate = updatedRestaurant;
              if (restaurantToUpdate != null) {
                await bloc.updateLandingRestaurantInformation(
                  restaurantToUpdate,
                  newLandingImage,
                );

                bool? success = await PlatformAlertDialog(
                  title: 'Profile updated',
                  content: 'The restaurant profile was updated successfully!',
                  defaultActionText: 'Ok',
                ).show(context);
                if (success != null) {
                  Navigator.pop(context);
                }
              }
            }
          },
          icon: const Icon(Icons.save),
          label: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Save',
                  style: TextStyle(fontSize: 10),
                ),
        );
      },
    );
  }

  void openPickerColor() {
    Color pickedColor = updatedRestaurant!.guestCheckInColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (newColor) {
                setState(
                  () {
                    pickedColor = newColor;
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                userColors.replaceRange(0, 1, [pickedColor]);
                setState(
                  () {
                    updatedRestaurant!.guestCheckInColor = pickedColor;
                  },
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
