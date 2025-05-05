import 'package:flutter/material.dart';
import 'package:myfirst_project/auto/login.dart';
import 'package:myfirst_project/hometabular.dart';
import 'package:myfirst_project/view.dart'; // use the correct import path
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'DJ App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: isLoggedIn ? const Hometabular() : const LoginPage(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DJ App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),  // <-- Make sure this points to your form version
    );
  }
}
