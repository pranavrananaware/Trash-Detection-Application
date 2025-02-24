import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Management"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          // Filter: Exclude Admins
          var users = snapshot.data!.docs.where((doc) {
            var role = doc['role'] ?? 'user'; // Default role is 'user'
            return role != 'admin'; // Exclude admin users
          }).toList();

          if (users.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index];
              String userId = userData.id;
              String username = userData['username'];
              String email = userData['email'];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      username[0].toUpperCase(),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  title: Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(email, style: TextStyle(color: Colors.grey[600])),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDeleteUser(context, userId, username);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Delete Confirmation Dialog
  void _confirmDeleteUser(BuildContext context, String userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete User"),
        content: Text("Are you sure you want to delete $username?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Delete"),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(userId);
            },
          ),
        ],
      ),
    );
  }

  // Delete User from Firestore
  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User deleted successfully.")),
      );
    } catch (e) {
      print("Error deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete user.")),
      );
    }
  }
}
