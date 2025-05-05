import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'view.dart';
import 'auto/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Hometabular(),
    );
  }
}

class Hometabular extends StatefulWidget {
  const Hometabular({super.key});

  @override
  State<Hometabular> createState() => _HometabularState();
}

class _HometabularState extends State<Hometabular> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> addName() async {
    final nameText = nameController.text.trim();
    final emailText = emailController.text.trim();
    final phoneText = phoneController.text.trim();

    if (nameText.isEmpty || emailText.isEmpty || phoneText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2/djproject/ali.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'djname': nameText,
          'email': emailText,
          'phonenumber': phoneText,
        }),
      );

      final responseData = jsonDecode(response.body);
      print("Response: ${response.body}");

      if (response.statusCode == 200 && responseData['status'] == true) {
        nameController.clear();
        emailController.clear();
        phoneController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "DJ added successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Insert failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server Error: $e")),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('djname');
    print('Session cleared and user logged out');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> showSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final djname = prefs.getString('djname') ?? 'N/A';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Session Info:\nLogged In: $isLoggedIn\nDJ Name: $djname"),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("DJ Area", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            tooltip: 'View Session Info',
            onPressed: showSessionInfo,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/dj.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'What’s your name?',
                    labelText: 'Enter your DJ name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => nameController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => emailController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    labelText: 'Phone Number',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => phoneController.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MaterialButton(
                  onPressed: addName,
                  color: Colors.black,
                  textColor: Colors.white,
                  child: const Text("Post"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ViewScreen()),
                    );
                  },
                  child: const Text('View all DJs'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
