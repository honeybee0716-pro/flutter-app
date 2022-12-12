import 'dart:core';
import 'package:flutter/material.dart';
import 'package:project1/common/models/restaurant.dart';

/// Contains the main layout for all intro sign in pages
/// (Logo, column setup etc)
class SignInPageMainLayout extends StatelessWidget {
  const SignInPageMainLayout(
      {Key? key, required this.restaurant, required this.columnChildren})
      : super(key: key);

  final Restaurant restaurant;
  final List<Widget> columnChildren;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            //   final bottom = MediaQuery.of(context).viewInsets.bottom;

            height: MediaQuery.of(context).size.height,
            decoration: restaurant.landingImage.isNotEmpty
                ? BoxDecoration(
                    image: DecorationImage(
                      image: Image.network(restaurant.landingImage).image,
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            child: Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.15,
                  right: MediaQuery.of(context).size.width * 0.15,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  ...columnChildren
                ],
              ),
            ),
          ),
        ));
  }
  // @override
  // Widget build(BuildContext context) {
  //   final list = <Widget>[];
  //   columnChildren.forEach((x) => list.add(Padding(
  //         padding: EdgeInsets.only(
  //             left: MediaQuery.of(context).size.width * 0.15,
  //             right: MediaQuery.of(context).size.width * 0.15),
  //         child: x,
  //       )));

  //   return Scaffold(
  //       resizeToAvoidBottomInset: false,
  //       backgroundColor: Colors.black,
  //       body: SingleChildScrollView(
  //         child: Padding(
  //           padding: EdgeInsets.only(
  //               bottom: MediaQuery.of(context).viewInsets.bottom),
  //           child: Column(
  //             children: [
  //               Center(
  //                 child: Image.network(
  //                   restaurant.landingImage,
  //                   width: MediaQuery.of(context).size.width,
  //                   height: MediaQuery.of(context).size.width * 0.33,
  //                   fit: BoxFit.fitWidth,
  //                 ),
  //               ),
  //               const SizedBox(
  //                 height: 70,
  //               ),
  //               ...list,
  //             ],
  //           ),
  //         ),
  //       ));
  // }
}



  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //       resizeToAvoidBottomInset: false,
  //       backgroundColor: Colors.black,
  //       body: SingleChildScrollView(
  //         child: Container(
  //           width: MediaQuery.of(context).size.width,
  //           //   final bottom = MediaQuery.of(context).viewInsets.bottom;

  //           height: MediaQuery.of(context).size.height,
  //           decoration: restaurant.landingImage.isNotEmpty
  //               ? BoxDecoration(
  //                   image: DecorationImage(
  //                     image: Image.network(restaurant.landingImage).image,
  //                     fit: BoxFit.cover,
  //                   ),
  //                 )
  //               : null,
  //           child: Padding(
  //             padding: EdgeInsets.only(
  //                 left: MediaQuery.of(context).size.width * 0.15,
  //                 right: MediaQuery.of(context).size.width * 0.15,
  //                 bottom: MediaQuery.of(context).viewInsets.bottom),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 const SizedBox(
  //                   height: 70,
  //                 ),
  //                 ...columnChildren
  //               ],
  //             ),
  //           ),
  //         ),
  //       ));
  // }
