import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")), // App Bar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  "assets/profile.jpg",
                ), // Replace with actual image
              ),
            ),
            const SizedBox(height: 20),

            // User Name
            const Text(
              "John Doe", // Replace with actual user name
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // Email
            const Text(
              "johndoe@example.com", // Replace with actual email
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Profile Options
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Edit Profile"),
              onTap: () {
                // Navigate to edit profile screen (to be implemented)
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Change Password"),
              onTap: () {
                // Navigate to change password screen (to be implemented)
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                // Navigate to settings screen (to be implemented)
              },
            ),
            const Divider(),

            // Logout Button
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                // Handle logout functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
