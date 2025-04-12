import 'package:flutter/material.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    final String imageUrl = args['imageUrl'] ?? '';
    final List<dynamic> detectedObjects = args['detectedObjects'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            imageUrl.isNotEmpty
                ? Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text('Image not available'),
                    ),
                  ),
            const SizedBox(height: 20),
            const Text(
              'Detected Objects',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: detectedObjects.isEmpty
                  ? const Center(
                      child: Text(
                        'No objects detected.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: detectedObjects.length,
                      itemBuilder: (context, index) {
                        final object = detectedObjects[index];
                        final label = object['label'] ?? 'Unknown';
                        final box = object['boundingBox'] ?? {};
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.search, color: Colors.green),
                            title: Text(label, style: const TextStyle(fontSize: 18)),
                            subtitle: box.isNotEmpty
                                ? Text(
                                    'Box: (L:${box['left']}, T:${box['top']}, R:${box['right']}, B:${box['bottom']})',
                                    style: const TextStyle(fontSize: 14),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
