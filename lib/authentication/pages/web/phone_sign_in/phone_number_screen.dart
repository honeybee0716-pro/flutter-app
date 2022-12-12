import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/sign_in_button.dart';
import 'package:project1/authentication/pages/web/phone_sign_in/sign_in_page_main_layout.dart';

import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';

import 'pinput_widget.dart';

const loginButtonsWidth = double.infinity;

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen(
      {Key? key, required this.user, required this.restaurant})
      : super(key: key);

  final FirebaseUser user;
  final Restaurant restaurant;
  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String initialCountry = kDebugMode ? 'GR' : 'US';
  PhoneNumber number = PhoneNumber(isoCode: kDebugMode ? 'GR' : 'US');

  bool isRegisterningPhone = false;
  bool isSendingOtp = false;

  bool isPhoneValid = false;
  final Key inputKey = GlobalKey();

  late TextEditingController phoneTextController;
  late Widget textWidget;

  @override
  void initState() {
    const textStyle = TextStyle(color: Colors.black, fontSize: 17);

    phoneTextController = TextEditingController();
    // we initialize it here to avoid rebuilding on setState
    //since this causes a problem with the cursor moving to the left
    textWidget = InternationalPhoneNumberInput(
      autofillHints: const [AutofillHints.telephoneNumber],
      selectorTextStyle: textStyle,
      spaceBetweenSelectorAndTextField: 0,
      textStyle: textStyle,
      inputDecoration: const InputDecoration(
        hintText: 'Phone Number',
        hintStyle: textStyle,
        enabledBorder: OutlineInputBorder(
            //  borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.transparent)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.transparent)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
      ),
      searchBoxDecoration: const InputDecoration(
        border: InputBorder.none,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.blue)),
        filled: false,
        // fillColor: Colors.white,
        contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
      ),
      onInputChanged: (PhoneNumber number) {
        this.number = number;
        // print('Phone Number Changed');
      },
      onInputValidated: (bool value) {
        if (value != isPhoneValid) {
          setState(() {
            isPhoneValid = value;
          });
        }
      },
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.DIALOG,
      ),
      ignoreBlank: false,
      autoValidateMode: AutovalidateMode.disabled,
      initialValue: number,
      textFieldController: phoneTextController,
      formatInput: true,
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: const OutlineInputBorder(),
      onSaved: (PhoneNumber number) {
        print('On Saved: $number');
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SignInPageMainLayout(restaurant: widget.restaurant, columnChildren: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: textWidget,
        ),
      ),
      const SizedBox(height: 20),
      SignInButton(
        label: 'Next',
        isEnabled: isPhoneValid,
        onTap: () {
          GoRouter.of(context).push(
              '/${widget.restaurant.shortUrl}/signin/phone/otp',
              extra:
                  OtpScreenArguments(widget.restaurant, number.phoneNumber!));
        },
      ),
    ]);
  }

  @override
  void dispose() {
    phoneTextController.dispose();
    super.dispose();
  }
}

class OtpScreenArguments {
  final Restaurant restaurant;
  final String phoneNumber;

  OtpScreenArguments(this.restaurant, this.phoneNumber);
}
