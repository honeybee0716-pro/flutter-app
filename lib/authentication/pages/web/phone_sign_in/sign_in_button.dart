import 'package:flutter/material.dart';
import 'package:project1/common/utils/hex_color.dart';

class SignInButton extends StatelessWidget {
  const SignInButton(
      {Key? key,
      required this.label,
      required this.onTap,
      this.isEnabled = true})
      : super(key: key);

  final String label;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 100,
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isEnabled ? HexColor('#6490E4') : Colors.grey,
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () {
          if (isEnabled) {
            onTap();
          }
        },
        child: Text(
          label,
          style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 20),
        ),
      ),
    );
  }
}
