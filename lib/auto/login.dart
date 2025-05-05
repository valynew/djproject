import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../hometabular.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController djnameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isLogin = true;

  // ✅ Save session
  Future<void> saveSession(String djname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('djname', djname);
    await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch ~/ 1000); // Save login time in seconds
  }

  // ✅ Check session on app start
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final loginTime = prefs.getInt('loginTime');

    if (isLoggedIn && loginTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now - loginTime <= 3600) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Hometabular()),
        );
      } else {
        await prefs.setBool('isLoggedIn', false);
        await prefs.remove('djname');
        await prefs.remove('loginTime');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your session has expired. Please log in again.")),
        );
      }
    }
  }

  Future<void> handleAuth() async {
    final djname = djnameController.text.trim();
    final password = passwordController.text.trim();

    if (djname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both DJ name and password.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('http://10.0.2.2/djproject/kali.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'djname': djname,
          'password': password,
          'action': isLogin ? 'login' : 'register'
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Success")),
        );

        await saveSession(djname);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Hometabular()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ✅ Added image here
                Image.asset(
                  'assets/images/koko.jpeg',
                  height: 150,
                ),
                const SizedBox(height: 20),
                Text(
                  isLogin ? 'Welcome back, DJ!' : 'Create your DJ account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: djnameController,
                  decoration: const InputDecoration(
                    labelText: 'DJ Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: handleAuth,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    backgroundColor: Colors.blue.shade800,
                  ),
                  child: Text(
                    isLogin ? "Login" : "Register",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Register here"
                        : "Already have an account? Login here",
                    style: const TextStyle(fontSize: 14),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
