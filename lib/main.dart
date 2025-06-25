import 'package:flutter/material.dart';
import 'package:supmap_clean/features/auth/login_page.dart';
//import 'package:supmap_clean/features/home/home_page.dart';
import 'features/navigation/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUPMAP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
    // home:  MainScreen(),
     home: const LoginPage(),
    );
  }
}