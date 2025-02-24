import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class TrashImagesDetectedScreen extends StatefulWidget {
  @override
  _TrashImagesDetectedScreenState createState() =>
      _TrashImagesDetectedScreenState();
}

class _TrashImagesDetectedScreenState extends State<TrashImagesDetectedScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trash Images Detected")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('trash_detections').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No trash images detected."));
          }

          var trashImages = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: trashImages.length,
            itemBuilder: (context, index) {
              var trashData = trashImages[index].data() as Map<String, dynamic>;

              String docId = trashImages[index].id;
              String imageUrl = trashData['imageUrl'] ?? '';
              String detectedObject =
                  trashData['detectedObject'] ?? 'Unknown Trash';

              String userName = (trashData.containsKey('userName') &&
                      trashData['userName'] != null &&
                      trashData['userName'].toString().trim().isNotEmpty)
                  ? trashData['userName'].toString()
                  : 'Unknown User';

              // 🔹 Location Handling for Google Maps Integration
              String location = "No Location Available"; // Default
              if (trashData.containsKey('location')) {
                var locData = trashData['location'];
                if (locData != null) {
                  if (locData is String && locData.trim().isNotEmpty) {
                    location = locData; // Use string location
                  } else if (locData is GeoPoint) {
                    location =
                        "Lat: ${locData.latitude}, Lng: ${locData.longitude}";
                  }
                }
              }

              String status = trashData['status'] ?? 'Pending Review';

              return _buildTrashImageCard(
                context,
                docId: docId,
                imageUrl: imageUrl,
                detectedObject: detectedObject,
                userName: userName,
                location: location,
                status: status,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrashImageCard(
    BuildContext context, {
    required String docId,
    required String imageUrl,
    required String detectedObject,
    required String userName,
    required String location,
    required String status,
  }) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: GestureDetector(
          onTap: () {
            _openFullImage(context, docId, imageUrl, userName);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey);
              },
            ),
          ),
        ),
        title: Text(detectedObject,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Captured by: $userName',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            GestureDetector(
              onTap: () => _openGoogleMaps(location),
              child: Text(
                'Location: $location',
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
              ),
            ),
            Text('Status: $status',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500, color: Colors.red)),
          ],
        ),
        trailing: IconButton(
          icon: _isDeleting
              ? const CircularProgressIndicator()
              : const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTrashImage(docId, imageUrl),
        ),
      ),
    );
  }

  void _openGoogleMaps(String location) async {
    if (location.contains('Lat:') && location.contains('Lng:')) {
      final regex = RegExp(r"Lat: ([\d.-]+), Lng: ([\d.-]+)");
      final match = regex.firstMatch(location);
      if (match != null) {
        String lat = match.group(1)!;
        String lng = match.group(2)!;
        final googleMapsUrl =
            "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
        if (await canLaunch(googleMapsUrl)) {
          await launch(googleMapsUrl);
        } else {
          throw 'Could not open Google Maps.';
        }
      }
    } else {
      final googleMapsSearchUrl =
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
      if (await canLaunch(googleMapsSearchUrl)) {
        await launch(googleMapsSearchUrl);
      } else {
        throw 'Could not open Google Maps.';
      }
    }
  }

  void _openFullImage(
      BuildContext context, String docId, String imageUrl, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageScreen(
          docId: docId,
          imageUrl: imageUrl,
          username: username,
          onDelete: () {
            _deleteTrashImage(docId, imageUrl);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _deleteTrashImage(String docId, String imageUrl) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('trash_detections')
          .doc(docId)
          .delete();
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trash image deleted successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting image: $e')));
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }
}

class FullImageScreen extends StatelessWidget {
  final String docId;
  final String imageUrl;
  final String username;
  final VoidCallback onDelete;

  const FullImageScreen({
    required this.docId,
    required this.imageUrl,
    required this.username,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trash Image Preview")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey);
                  },
                ),
              ),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
