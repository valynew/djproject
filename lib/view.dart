import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ViewScreen(),
  ));
}

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<dynamic> users = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    final url = Uri.parse('http://192.168.1.193/djproject/ali.php');

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
          showError(jsonResponse['message'] ?? "No DJs found.");
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse('http://192.168.1.193/djproject/ali.php');
    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == true) {
        setState(() {
          users.removeWhere((user) => user['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Delete failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
        title: const Text('All DJs', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUpdateScreen()),
              ).then((_) => fetchData());
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('No DJs found.'))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(user['djname'][0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              title: Text(user['djname']),
              subtitle: Text('${user['email']} • ${user['phonenumber']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteUser(user['id']),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddUpdateScreen(
                      djData: user,
                      isUpdate: true,
                    ),
                  ),
                ).then((_) => fetchData());
              },
            ),
          );
        },
      ),
    );
  }
}

class AddUpdateScreen extends StatefulWidget {
  final dynamic djData;
  final bool isUpdate;

  const AddUpdateScreen({super.key, this.djData, this.isUpdate = false});

  @override
  State<AddUpdateScreen> createState() => _AddUpdateScreenState();
}

class _AddUpdateScreenState extends State<AddUpdateScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.djData != null) {
      nameController.text = widget.djData['djname'];
      emailController.text = widget.djData['email'];
      phoneController.text = widget.djData['phonenumber'];
    }
  }

  Future<void> saveData() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final url = Uri.parse('http://192.168.1.193/djproject/ali.php');
    final payload = {
      'djname': name,
      'email': email,
      'phonenumber': phone,
    };

    if (widget.isUpdate && widget.djData['id'] != null) {
      payload['id'] = widget.djData['id'];
    }

    try {
      final response = await (widget.isUpdate
          ? http.put(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
          : http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload)));

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Success!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Failed to save data")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.isUpdate ? 'Update DJ' : 'Add DJ'),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'DJ Name', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: saveData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              child: Text(
                widget.isUpdate ? 'Update DJ' : 'Add DJ',
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
