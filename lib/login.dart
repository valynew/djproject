import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hometabular extends StatelessWidget {
  const Hometabular({Key? key}) : super(key: key);

  // Function to get the DJ name from SharedPreferences
  Future<String> getDjName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('djname') ?? 'Unknown DJ';  // Default to 'Unknown DJ' if not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: getDjName(),  // Fetch the DJ name from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());  // Show loading indicator while fetching data
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));  // Handle any errors
          }

          final djName = snapshot.data ?? 'Unknown DJ';
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $djName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'This is the home screen. You can add your content here.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // You can implement the logic to log the user out or navigate to a different screen
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();  // Clear shared preferences (log out)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Hometabular()),  // Redirect to login screen or another page
                    );
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
