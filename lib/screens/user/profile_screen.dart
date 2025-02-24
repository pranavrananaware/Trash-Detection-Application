import 'package:flutter/material.dart';
import 'package:trashhdetection/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final String profilePicUrl;

  ProfileScreen({
    required this.username,
    required this.email,
    required this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the home screen
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profilePicUrl),
            ),
            SizedBox(height: 16),
            
            // Display Username
            Text(
              username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,  // Ensure the text doesn't overflow
            ),
            SizedBox(height: 8),
            
            // Display Email
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
              overflow: TextOverflow.ellipsis,  // Ensure the text doesn't overflow
            ),
            SizedBox(height: 32),

            // Notifications ListTile
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notifications"),
              onTap: () {
                // Navigate to notifications settings
              },
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text("Security"),
              onTap: () {
                // Navigate to security settings
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
              onTap: () {
                // Clear any stored data (if needed)
                // Navigate to the Login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Navigate back to the previous screen
              },
              child: const Text(
                "Back",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,  // Color for the back text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
