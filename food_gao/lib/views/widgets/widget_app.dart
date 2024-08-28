import 'package:flutter/material.dart';
import 'package:food_gao/routs/app_routs.dart';
import 'package:food_gao/views/auth/auth_screen.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_services.dart'; // Import AuthProvider

class WidgetApp {
  final BuildContext context;

  WidgetApp({required this.context});

  // Logout dialog
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                // Access the AuthProvider using Provider.of or context.read
                final authProvider = Provider.of<AuthProvider>(context, listen: false);

                await authProvider.userLogout(); // Use the userLogout method from AuthProvider

                Navigator.of(context).pop(); // Close the dialog after logout
                sendToPageReplacement(context: context, page: PhoneAuthView());
              },
            ),
          ],
        );
      },
    );
  }
}
