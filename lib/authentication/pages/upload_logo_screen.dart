import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project1/authentication/blocs/authentication_bloc.dart';
import 'package:project1/authentication/components/authentication_button.dart';
import 'package:project1/authentication/components/footer.dart';
import 'package:project1/authentication/pages/route_screen.dart';
import 'package:project1/common/components/custom_dialog.dart';
import 'package:project1/common/utils/utils.dart';
import 'package:provider/provider.dart';

class UploadLogoScreen extends StatefulWidget {
  const UploadLogoScreen({Key? key}) : super(key: key);

  @override
  State<UploadLogoScreen> createState() => _UploadLogoScreenState();
}

class _UploadLogoScreenState extends State<UploadLogoScreen> {
  File? restaurantLogo;
  late AuthenticationBLoc bloc = context.read<AuthenticationBLoc>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 10,
              child: IconButton(
                onPressed: () {
                  bloc.skipToUploadLogo.value = true;
                },
                icon: const Icon(Icons.close),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: bloc.uploadLogoCompleted,
              child: buildUploadLogoBody(),
              builder: (context, bool uploadCompletd, child) {
                return uploadCompletd ? const SizedBox() : child!;
              },
            ),
            buildSuccessMessage(context),
            const Positioned(
              bottom: 0,
              child: Center(
                child: Footer(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _uploadFile() async {
    final logo = restaurantLogo;
    if (logo == null) {
      _showUploadWithErrorsDialog();
    } else {
      if (bloc.uploadLogoCompleted.value) {
        bloc.uploadLogoCompleted.value = false;
        navigateToPushReplace(
          context,
          const RouteScreen(),
        );
      } else {
        final successful = await bloc.uploadRestaurantLogo(logo);
        if (successful) {
        } else {
          _showUploadWithErrorsDialog();
        }
      }
    }
  }

  void _showUploadWithErrorsDialog() {
    PlatformAlertDialog(
            title: 'Upload failed',
            content: 'Please pick a picture before upload it!',
            defaultActionText: 'Ok')
        .show(context);
  }

  Widget buildUploadLogoBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SizedBox(height: 36),
            ],
          ),
          const Text(
            'Step 2 \nAdd your logo',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: restaurantLogo == null ? 150 : 50,
          ),
          if (restaurantLogo != null) _buildLogoViewer(),
          Center(
            child: ValueListenableBuilder(
              valueListenable: bloc.loading,
              builder: (context, bool loading, _) {
                return !loading
                    ? SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () async {
                            restaurantLogo = await pickImage();
                            setState(() {});
                          },
                          child: const Text(
                            'Add a photo',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox();
              },
            ),
          ),
          const SizedBox(
            height: 100,
          ),
          Center(
            child: AuthenticationButton(
              loadingListenable: bloc.loading,
              action: _uploadFile,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSuccessMessage(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: bloc.uploadLogoCompleted,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Success!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 72,
            ),
            AuthenticationButton(
              loadingListenable: bloc.loading,
              action: _uploadFile,
            )
          ],
        ),
      ),
      builder: (context, bool uploadCompleted, child) {
        return uploadCompleted ? child! : const SizedBox();
      },
    );
  }

  Widget _buildLogoViewer() {
    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              restaurantLogo!,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
