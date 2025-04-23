import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<dynamic> users = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    final url = Uri.parse('http://192.168.1.193/djproject/ali.php'); // Your PHP backend URL

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == true) {
          setState(() {
            users = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          showError(jsonResponse['message']);
        }
      } else {
        showError("Server error: ${response.statusCode}");
      }
    } catch (e) {
      showError("Error: $e");
    }
  }

  void showError(String message) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All DJs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black, // Optional background highlight for text
          ),
        ),
        backgroundColor: Colors.black,
      ),


      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('No users found.'))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  user['djname'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user['djname']),
              subtitle: Text('${user['email']} • ${user['phonenumber']}'),
            ),
          );
        },
      ),
    );
  }


}

mixin colors {
}