import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/style/mynuu_colors.dart';

class AuthenticationButton extends StatelessWidget {
  const AuthenticationButton({
    Key? key,
    required this.loadingListenable,
    required this.action,
  }) : super(key: key);

  final ValueListenable<bool> loadingListenable;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: loadingListenable,
      child: Container(
        width: 50,
        height: 50,
        child: Transform.scale(
          scale: .5,
          child: Image.asset(
            'assets/exit.png',
          ),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: mynuuPrimary,
          ),
          shape: BoxShape.circle,
        ),
      ),
      builder: (context, bool loading, child) {
        return GestureDetector(
          onTap: action,
          child: loading
              ? const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : child,
        );
      },
    );
  }
}
