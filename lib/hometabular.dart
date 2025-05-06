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
  final TextEditingController profileNameController = TextEditingController();
  final TextEditingController profilePasswordController = TextEditingController();

  String djName = '';

  @override
  void initState() {
    super.initState();
    loadSessionData();
  }

  Future<void> loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('djname') ?? '';
    setState(() {
      djName = storedName;
      profileNameController.text = storedName;
    });
  }

  Future<void> updateProfileName() async {
    final newName = profileNameController.text.trim();
    final newPassword = profilePasswordController.text.trim();

    if (newName.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Password cannot be empty.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final oldName = prefs.getString('djname') ?? '';

    final url = Uri.parse('http://10.0.2.2/djproject/updateprofile.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'oldname': oldName,
          'newname': newName,
          'newpassword': newPassword,
        }),
      );

      print("Update response: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['status'] == true) {
            await prefs.setString('djname', newName);
            setState(() {
              djName = newName;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? "Profile updated.")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? "Update failed.")),
            );
          }
        } catch (e) {
          print("JSON Decode Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid response from server.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Update Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not update profile.")),
      );
    }
  }

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

    final url = Uri.parse('http://10.0.2.2/djproject/kali.php');

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

  void showEditProfileSheet() {
    profilePasswordController.clear(); // Clear password on open
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Your Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: profileNameController,
                decoration: const InputDecoration(
                  labelText: 'New DJ Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: profilePasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  updateProfileName();
                  Navigator.pop(context);
                },
                child: const Text("Edit"),
              ),
            ],
          ),
        );
      },
    );
  }

  void showProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_pin, size: 50, color: Colors.black54),
              const SizedBox(height: 10),
              Text(
                djName.isNotEmpty ? djName : "Unknown User",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                onPressed: () {
                  Navigator.pop(context);
                  showEditProfileSheet();
                },
              ),
              const Divider(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  logout();
                },
              ),
            ],
          ),
        );
      },
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
            icon: const Icon(Icons.info, color: Colors.white, size: 28),
            tooltip: 'View Session Info',
            onPressed: showSessionInfo,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white, size: 36),
              tooltip: 'Profile / Logout',
              onPressed: showProfileSheet,
            ),
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
                const Divider(height: 30, thickness: 1),
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
