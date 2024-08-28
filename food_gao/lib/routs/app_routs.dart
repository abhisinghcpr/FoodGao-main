import 'package:flutter/material.dart';
import 'package:food_gao/views/home/home_screen.dart';
import 'package:food_gao/views/profile/profile_screen.dart';

const homePage = HomeScreen();
const profilePage = ProfileScreen();

sendToPageReplacement({required BuildContext context, required Widget page}) {
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}

sendToPagePush({required BuildContext context, required Widget page}) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}
sendToBackPage({required BuildContext context,}) {
  Navigator.of(context).pop();

}