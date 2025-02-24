import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DetectionScreen extends StatefulWidget {
  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  File? _image;
  final picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Call YOLOv8 model for detection here
      _runObjectDetection(_image!);
    }
  }

  // Function to capture an image using the camera
  Future<void> _captureImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Call YOLOv8 model for detection here
      _runObjectDetection(_image!);
    }
  }

  // Placeholder function for YOLOv8 detection (to be implemented)
  Future<void> _runObjectDetection(File image) async {
    // TODO: Implement YOLOv8 model inference
    print("Running YOLOv8 detection on image: ${image.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trash Detection")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image == null
              ? Text("No image selected", style: TextStyle(fontSize: 16))
              : Image.file(_image!, height: 300), // Display selected image

          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text("Select Image"),
              ),
              SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: Icon(Icons.camera_alt),
                label: Text("Capture Image"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
