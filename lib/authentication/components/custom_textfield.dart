import 'package:flutter/material.dart';
import 'package:project1/common/style/mynuu_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final Color? backgroundColor;
  final Color? enabledBorderColor;
  final Color? textColor;
  final TextEditingController controller;
  final bool readOnly;
  final void Function(String)? onChanged;
  final VoidCallback? onClick;
  final Iterable<String>? autofillHints;

  final String? Function(String?)? validator;
  const CustomTextField(
      {Key? key,
      required this.hintText,
      required this.prefixIcon,
      this.suffixIcon,
      this.obscureText,
      this.validator,
      required this.controller,
      this.onChanged,
      this.backgroundColor,
      this.enabledBorderColor,
      this.readOnly = false,
      this.onClick,
      this.autofillHints,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: textColor != null
          ? TextStyle(
              color: textColor!,
            )
          : null,
      autofillHints: autofillHints,
      onTap: () {
        if (onClick != null) {
          onClick!();
        }
      },
      readOnly: readOnly,
      controller: controller,
      cursorColor: textColor,
      obscureText: obscureText ?? false,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor ?? mynuuDarkGrey,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(
            color: enabledBorderColor ?? Colors.transparent,
          ),
          gapPadding: 120,
        ),
        hintStyle: textColor != null
            ? TextStyle(
                color: textColor!,
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          borderSide: BorderSide(color: Colors.red),
          gapPadding: 120,
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
