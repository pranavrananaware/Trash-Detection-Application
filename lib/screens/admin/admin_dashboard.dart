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
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text("Welcome, Admin 👋"),
        backgroundColor: Colors.indigo,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSettingsScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.people_alt_rounded,
              iconColor: Colors.deepPurple,
              title: "User Management",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => UserManagementScreen()));
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.bar_chart_rounded,
              iconColor: Colors.teal,
              title: "Analytics",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminAnalyticsScreen()));
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.image_rounded,
              iconColor: Colors.orange,
              title: "Trash Images",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TrashImagesDetectedScreen()));
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.report_gmailerrorred_rounded,
              iconColor: Colors.redAccent,
              title: "Trash Reports",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ManageTrashReportsScreen()));
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.notifications_active_rounded,
              iconColor: Colors.pink,
              title: "Notifications",
              onTap: () {
                // Notification screen
              },
            ),
            _buildDashboardCard(
              context,
              icon: Icons.settings_applications_rounded,
              iconColor: Colors.blueGrey,
              title: "Settings",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminSettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(3, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
