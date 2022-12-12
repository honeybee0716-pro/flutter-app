import 'package:flutter/material.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/pages/home_screen.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: context.read<FirebaseUser>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: HomeScreen(firebaseUser: context.read<FirebaseUser>()),
        ),
      ),
    );
  }
}
