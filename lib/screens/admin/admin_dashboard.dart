import 'package:flutter/material.dart';
import 'package:trashhdetection/screens/admin/admin_setting.dart';
import 'package:trashhdetection/screens/admin/trashreport.dart';
import 'package:trashhdetection/screens/admin/user_management.dart';
import 'package:trashhdetection/screens/user/profile_screen.dart';
import 'package:trashhdetection/screens/admin/admin_analytics_screen.dart';
import 'package:trashhdetection/screens/admin/trashimage.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String username;
  final String email;

  AdminDashboardScreen({
    required this.username,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
            shrinkWrap: true,
            children: [
              _buildDashboardCard(
                context,
                icon: Icons.people,
                title: "User Management",  // Changed title to "User Management"
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserManagementScreen(),
                    ),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.analytics,
                title: "Statistics & Analytics",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminAnalyticsScreen()),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.image,
                title: "Trash Images Detected",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrashImagesDetectedScreen()),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.report,
                title: "Manage Trash Reports",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageTrashReportsScreen()),
                  );
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {
                  // Navigate to notification management screen
                },
              ),
              _buildDashboardCard(
                context,
                icon: Icons.settings,
                title: "Settings",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminSettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
