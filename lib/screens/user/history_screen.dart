import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> detectionHistory;

  HistoryScreen({required this.detectionHistory, required List<String> historyList});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches username based on the user ID stored in Firestore
  Future<String> _fetchUsername(String userId) async {
    if (userId.isEmpty) {
      print("DEBUG: User ID is empty");
      return 'Unknown User';
    }

    try {
      print("DEBUG: Fetching username for userId: $userId");

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('username')) {
          print("DEBUG: Username found: ${data['username']}");
          return data['username'] ?? 'Unknown User';
        } else {
          print("DEBUG: Username field missing in document: ${userDoc.data()}");
        }
      } else {
        print("DEBUG: No user document found for userId: $userId");
      }
    } catch (e) {
      print("ERROR fetching username: $e");
    }
    return 'Unknown User';
  }

  /// Deletes the selected history item from Firestore and Firebase Storage
  Future<void> _deleteItem(int index, String? docId, String? imageUrl) async {
    setState(() {
      widget.detectionHistory.removeAt(index);
    });

    if (docId != null) {
      await _firestore.collection('trash_detections').doc(docId).delete();
    }

    if (imageUrl != null && imageUrl.startsWith('http')) {
      try {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      } catch (e) {
        print("Error deleting image from Firebase Storage: $e");
      }
    }
  }

  /// Opens a full-screen image view
  void _openFullScreenImage(String imagePath) {
    if (imagePath.startsWith('http') || File(imagePath).existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageScreen(imagePath: imagePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image not found: $imagePath")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("DEBUG: Full Detection History: ${widget.detectionHistory}"); // Debugging

    return Scaffold(
      appBar: AppBar(title: const Text('Detection History')),
      body: widget.detectionHistory.isEmpty
          ? const Center(child: Text('No history available'))
          : ListView.builder(
              itemCount: widget.detectionHistory.length,
              itemBuilder: (context, index) {
                var item = widget.detectionHistory[index];
                String detectedObjects = item['detectedObjects'] ?? "No objects detected";
                String imagePath = item['imagePath'] ?? "";
                String? imageUrl = item['imageUrl'];
                String? docId = item['docId'];
                String userId = item['userId'] ?? ""; // Ensure userId exists

                return FutureBuilder<String>(
                  future: _fetchUsername(userId),
                  builder: (context, snapshot) {
                    String username = snapshot.data ?? 'Unknown User';

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _openFullScreenImage(imageUrl ?? imagePath),
                            child: imageUrl != null
                                ? Image.network(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover)
                                : (File(imagePath).existsSync()
                                    ? Image.file(File(imagePath), width: double.infinity, height: 200, fit: BoxFit.cover)
                                    : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Timestamp: ${item['timestamp'] ?? 'No Timestamp'}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Detected Objects: $detectedObjects',
                                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Captured by: $username',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteItem(index, docId, imageUrl),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// Full-screen image view
class FullScreenImageScreen extends StatelessWidget {
  final String imagePath;

  FullScreenImageScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen Image'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: imagePath.startsWith('http')
            ? Image.network(imagePath, fit: BoxFit.contain)
            : File(imagePath).existsSync()
                ? Image.file(File(imagePath), fit: BoxFit.contain)
                : const Text("Image not found"),
      ),
    );
  }
}