import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics & Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Card for Total Users (Real-time data from Firestore)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data.'));
                }
                int totalUsers = snapshot.data!.docs.length;

                return _buildStatisticsCard(
                  title: 'Total Users',
                  count: totalUsers.toString(),
                  icon: Icons.people,
                );
              },
            ),

            // Card for Total Notifications Received (Static for now, replace with Firestore if needed)
            _buildStatisticsCard(
              title: 'Total Notifications Received',
              count: '1500',
              icon: Icons.notifications,
            ),

            // Card for Total Notifications Sent
            _buildStatisticsCard(
              title: 'Notifications Sent',
              count: '1200',
              icon: Icons.notifications_active,
            ),

            const SizedBox(height: 20),

            // Analytics Section
            _buildAnalyticsCard(
              title: 'Notifications Trend',
              description: 'Analytics chart showing notifications sent/received over time.',
              onTap: () {
                // Navigate to notifications trend page or show chart
              },
            ),

            const SizedBox(height: 30),

            // Insights Section
            _buildInsightsCard(
              title: 'Analytics Insights',
              description:
                  'This section provides deeper insights into user behavior and notifications engagement.',
              icon: Icons.insights,
              onTap: () {
                // Navigate to detailed insights page
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method for Statistics Cards
  Widget _buildStatisticsCard({
    required String title,
    required String count,
    required IconData icon,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, size: 45, color: Colors.blueAccent),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('Count: $count', style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Method for Analytics Cards
  Widget _buildAnalyticsCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(description, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }

  // Advanced Insights Card
  Widget _buildInsightsCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, size: 45, color: Colors.greenAccent),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(description, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward, color: Colors.greenAccent),
        onTap: onTap,
      ),
    );
  }
} 