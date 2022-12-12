import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformAlertDialog {
  PlatformAlertDialog({
    required this.title,
    required this.content,
    this.cancelActionText,
    required this.defaultActionText,
  });

  final String title;
  final String content;
  final String? cancelActionText;
  final String defaultActionText;

  Future<bool?> show(BuildContext context) async {
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, anim1, anim2) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: Theme.of(context).backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Container(
          child: _buildModalBody(context),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) =>
          _buildChild(anim1, child),
      context: context,
    );
  }

  Widget _buildChild(Animation<double> anim1, Widget child) {
    if (kIsWeb) {
      return FadeTransition(opacity: anim1, child: child);
    }
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 3 * anim1.value,
        sigmaY: 3 * anim1.value,
      ),
      child: FadeTransition(
        child: child,
        opacity: anim1,
      ),
    );
  }

  Widget _buildModalBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: const EdgeInsets.only(
          left: 30,
          top: 20,
          right: 35,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA8A8A8),
              ),
            ),
            const SizedBox(height: 20),
            _buildActions(context)
          ],
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: cancelActionText != null
          ? MainAxisAlignment.spaceAround
          : MainAxisAlignment.end,
      children: [
        if (cancelActionText != null)
          SizedBox(
            width: 120,
            height: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelActionText ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).disabledColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(120.0),
                    side: const BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(
          width: 120,
          height: 40,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              defaultActionText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}
