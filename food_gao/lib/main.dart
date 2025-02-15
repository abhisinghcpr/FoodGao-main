import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_gao/services/firebase_services.dart';
import 'package:food_gao/views/auth/PersonalDetailsScreen.dart';
import 'package:food_gao/views/home/splash_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider(),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FoodGaon',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: RegisterScreen(),
      ),
    );
  }
}
