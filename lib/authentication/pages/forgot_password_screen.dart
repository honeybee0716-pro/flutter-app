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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late AuthenticationBLoc bloc = context.read<AuthenticationBLoc>();

  final GlobalKey<FormState> forgotPasswordForm = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();

  late final appleSignInAvailable = context.read<AppleSignInAvailable>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const SizedBox(
        height: 100,
        child: Footer(),
      ),
      body: SafeArea(
        child: Form(
          key: forgotPasswordForm,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            children: [
              const SizedBox(
                height: 36,
              ),
              const Text(
                'Forgot you \npassword',
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
                controller: email,
                hintText: 'Email to send a recovery link',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recover',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  AuthenticationButton(
                    loadingListenable: bloc.loading,
                    action: () async {
                      if (forgotPasswordForm.currentState!.validate()) {
                        //forgotPasswordForm.currentState!.save();
                        await _sendEmailRecovery(context);
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

  Future<void> _sendEmailRecovery(BuildContext context) async {
    try {
      await bloc.sendPasswordResetEmail(email.text);
      await PlatformAlertDialog(
              content:
                  'We\'ve sent a verification link to ${email.text}, please review your inbox.',
              title: 'Check your email',
              defaultActionText: 'Ok')
          .show(context);
      Navigator.pop(context);
    } on PlatformException catch (e) {
      await _showSignInError(context, e.code);
    } catch (e) {
      await _showSignInError(
        context,
        e.toString(),
      );
    }
  }

  Future<void> _showSignInError(BuildContext context, String? message) async {
    await PlatformAlertDialog(
            content: message?.replaceAll('firebase_auth/', '') ??
                'There was a problem, try it later!',
            title: 'Password recovery failed',
            defaultActionText: 'Ok')
        .show(context);
  }
}
