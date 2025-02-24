import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Settings"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // Handle save settings action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings Saved')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSettingsSection(
              title: "General Settings",
              children: [
                _buildSwitchTile(
                  context,
                  title: "Enable Dark Mode",
                  value: false,
                  onChanged: (bool value) {
                    // Handle Dark Mode toggle
                  },
                ),
                _buildSwitchTile(
                  context,
                  title: "Enable Push Notifications",
                  value: true,
                  onChanged: (bool value) {
                    // Handle Push Notifications toggle
                  },
                ),
              ],
            ),
            _buildSettingsSection(
              title: "Account Settings",
              children: [
                _buildTextField(
                  context,
                  label: "Admin Email",
                  initialValue: "admin@example.com",
                  onChanged: (value) {
                    // Handle admin email change
                  },
                ),
                _buildTextField(
                  context,
                  label: "Admin Phone Number",
                  initialValue: "+1 123 456 7890",
                  onChanged: (value) {
                    // Handle admin phone number change
                  },
                ),
              ],
            ),
            _buildSettingsSection(
              title: "Security Settings",
              children: [
                _buildSwitchTile(
                  context,
                  title: "Two-Factor Authentication",
                  value: true,
                  onChanged: (bool value) {
                    // Handle 2FA toggle
                  },
                ),
                _buildButtonTile(
                  context,
                  title: "Change Password",
                  onPressed: () {
                    // Navigate to Change Password screen
                  },
                ),
              ],
            ),
            _buildSettingsSection(
              title: "App Preferences",
              children: [
                _buildDropdownTile(
                  context,
                  title: "Language",
                  value: "English",
                  items: ["English", "Spanish", "French"],
                  onChanged: (value) {
                    // Handle language change
                  },
                ),
                _buildDropdownTile(
                  context,
                  title: "Time Zone",
                  value: "GMT",
                  items: ["GMT", "EST", "CST", "PST"],
                  onChanged: (value) {
                    // Handle time zone change
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            // 🚀 Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // Helper for creating a section of settings
  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  // Switch tile widget for boolean settings
  Widget _buildSwitchTile(BuildContext context, {required String title, required bool value, required Function(bool) onChanged}) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  // TextField tile for settings with user input
  Widget _buildTextField(BuildContext context, {required String label, required String initialValue, required Function(String) onChanged}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  // Button tile for clickable actions
  Widget _buildButtonTile(BuildContext context, {required String title, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }

  // Dropdown tile widget for selecting from a list
  Widget _buildDropdownTile(BuildContext context, {required String title, required String value, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(),
      ),
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  // ✅ Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          "Logout",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut(); // ✅ Logs out the admin
            Navigator.pushReplacementNamed(context, '/login'); // ✅ Redirects to login screen
          } catch (e) {
            print("Logout failed: $e"); // ✅ Debugging (check console for errors)
          }
        },
      ),
    );
  }
}
