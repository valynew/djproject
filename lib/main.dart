import 'package:flutter/material.dart';
import 'package:myfirst_project/auto/login.dart';
import 'package:myfirst_project/hometabular.dart';
import 'package:myfirst_project/view.dart'; // use the correct import path

void main() {
  runApp(const MyApp());
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
