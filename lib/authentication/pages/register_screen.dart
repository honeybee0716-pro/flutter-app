import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/authentication/components/authentication_button.dart';
import 'package:project1/authentication/components/custom_textfield.dart';
import 'package:project1/authentication/components/footer.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/services/apple_sign_in_available.dart';
import 'package:project1/common/utils/utils.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late AuthenticationBLoc bloc = context.read<AuthenticationBLoc>();

  final GlobalKey<FormState> registerForm = GlobalKey<FormState>();

  TextEditingController restaurant = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  late final appleSignInAvailable = context.read<AppleSignInAvailable>();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SizedBox(
        height: 100,
        child: Footer(),
      ),
      body: SafeArea(
        child: Form(
          key: registerForm,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            children: [
              const SizedBox(
                height: 36,
              ),
              const Text(
                'Create an \naccount',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 36,
              ),
              CustomTextField(
                controller: restaurant,
                hintText: 'Restaurant or bar name',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Field is required';
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: name,
                hintText: 'Your name',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Field is required';
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: email,
                hintText: 'Email',
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  color: Colors.white,
                ),
                validator: (value) {
                  return validateEmail(value ?? '');
                },
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                controller: password,
                hintText: 'Password',
                prefixIcon: const Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                ),
                obscureText: !_passwordVisible,
                validator: (value) {
                  if (value!.isEmpty) return 'Field is required';
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              CustomTextField(
                  controller: confirmPassword,
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white,
                    ),
                  ),
                  obscureText: !_confirmPasswordVisible,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Field is required';
                    } else if (value != password.text) {
                      return 'The password does not match';
                    }
                    return null;
                  }),
              const SizedBox(height: 55),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'sign up with',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _signInWithGoogle(context),
                            child: Image.asset(
                              'assets/google_round_sign_in.png',
                              width: 50,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          if (appleSignInAvailable.isAvailable)
                            GestureDetector(
                              onTap: () => _signInWithApple(context),
                              child: Image.asset(
                                'assets/apple.png',
                                width: 50,
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                  AuthenticationButton(
                    loadingListenable: bloc.loading,
                    action: () async {
                      if (registerForm.currentState!.validate()) {
                        registerForm.currentState!.save();
                        await _registerUserWithEmailAndPassword(context);
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerUserWithEmailAndPassword(BuildContext context) async {
    try {
      await bloc.createUserWithEmailAndPassword(
        email: email.text,
        password: password.text,
        restaurantName: restaurant.text,
        ownerName: name.text,
      );
    } on PlatformException catch (e) {
      await _showSignInError(context, e.code);
    } catch (e) {
      await _showSignInError(
        context,
        e.toString(),
      );
    }
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await bloc.signInWithGoogle();
      Navigator.pop(context);
    } on PlatformException catch (e) {
      _showSignInError(context, e.message);
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    try {
      await bloc.signInWithApple();
      Navigator.pop(context);
    } on PlatformException catch (e) {
      _showSignInError(context, e.message);
    }
  }

  Future<void> _showSignInError(BuildContext context, String? message) async {
    await PlatformAlertDialog(
            content: message?.replaceAll('firebase_auth/', '') ??
                'There was a problem, try it later!',
            title: 'Register failed',
            defaultActionText: 'Ok')
        .show(context);
  }
}
