import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project1/authentication/components/custom_textfield.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/utils/utils.dart';
import 'package:project1/profile_management/blocs/edit_profile_bloc.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> editForm = GlobalKey<FormState>();
  final TextEditingController _restaurantController = TextEditingController();
  late EditProfileBloc bloc = EditProfileBloc();

  Restaurant? initialRestaurant;
  Restaurant? updatedRestaurant;

  File? newRestaurantLogo;

  bool firstRun = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Image.asset(
          'assets/logo-2.png',
          width: 100,
        ),
        actions: [
          _buildSaveAction(),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Restaurant>(
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
            if (firstRun) {
              _restaurantController.text = restaurant.restaurantName;
              firstRun = false;
            }

            return Form(
              key: editForm,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  _buildLogoWidget(restaurant),
                  ..._buildProfileMetaData(restaurant),
                  CustomTextField(
                    controller: _restaurantController,
                    hintText: 'Restaurant or bar name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                    ),
                    onChanged: (newValue) {
                      setState(() {
                        updatedRestaurant?.restaurantName = newValue;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) return 'Field is required';
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildProfileMetaData(Restaurant restaurant) {
    return [
      const SizedBox(
        height: 10,
      ),
      Center(
        child: Text(
          restaurant.ownerName,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      Center(
        child: Text(
          restaurant.email,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(
        height: 30,
      ),
    ];
  }

  Widget _buildSaveAction() {
    return ValueListenableBuilder(
      valueListenable: bloc.loading,
      builder: (context, bool loading, _) {
        if (loading) {
          return const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
        return TextButton(
          onPressed: () async {
            // save profile edit
            if (editForm.currentState!.validate()) {
              final restaurantToUpdate = updatedRestaurant;
              if (restaurantToUpdate != null) {
                await bloc.updateRestaurantProfile(
                  restaurantToUpdate,
                  newRestaurantLogo,
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
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoWidget(Restaurant restaurant) {
    return GestureDetector(
      onTap: () async {
        // change the image here.
        newRestaurantLogo = await pickImage();
        setState(() {});
      },
      child: newRestaurantLogo == null
          ? CircleAvatar(
              backgroundImage: restaurant.logo.isEmpty
                  ? null
                  : NetworkImage(restaurant.logo),
              child: const Center(
                child: Icon(Icons.edit),
              ),
              radius: 75,
            )
          : SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        newRestaurantLogo!,
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.edit),
                  )
                ],
              ),
            ),
    );
  }
}
