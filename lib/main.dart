import 'package:flutter/material.dart';
import 'package:myfirst_project/hometabular.dart'; // use the correct import path

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
      home: const Hometabular(),  // <-- Make sure this points to your form version
    );
  }
}
