import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class CameraScreen extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onImageCaptured;
  final String username;

  CameraScreen({required this.onImageCaptured, required this.username});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isUploading = false;
  final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isUploading = true);

      XFile file = await _controller!.takePicture();
      Directory tempDir = await getTemporaryDirectory();
      String imagePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      File savedImage = File(imagePath);
      await file.saveTo(imagePath);

      List<String> detectedObjects = await _detectObjects(savedImage);
      String location = await _getCityName();

      Map<String, dynamic> historyItem = {
        'imagePath': imagePath,
        'detectedObjects': detectedObjects.join(', '),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await _saveToHistory(historyItem);

      String? imageUrl = await _uploadImageToFirebase(savedImage);
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('trash_detections').add({
          'imageUrl': imageUrl,
          'detectedObject': detectedObjects.join(', '),
          'timestamp': DateTime.now(),
          'username': widget.username,
          'location': location,
          'status': 'Pending Review',
        });
      }
      widget.onImageCaptured([historyItem]);
      setState(() => _isUploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Captured & Uploaded Successfully')));
    } catch (e) {
      setState(() => _isUploading = false);
      print('Error capturing image: $e');
    }
  }

  Future<String> _getCityName() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String area = placemarks[0].subLocality ?? '';
        String city = placemarks[0].locality ?? 'Unknown City';
        return area.isNotEmpty ? '$area, $city' : city;
      } else {
        return 'Unknown City';
      }
    } catch (e) {
      print("Error getting location: $e");
      return 'Unknown City';
    }
  }

  Future<List<String>> _detectObjects(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    return labels.map((label) => label.label).toList();
  }

  Future<void> _saveToHistory(Map<String, dynamic> historyItem) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList('trash_detections') ?? [];
    historyList.add(jsonEncode(historyItem));
    await prefs.setStringList('trash_detections', historyList);
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = "detection_${DateTime.now().millisecondsSinceEpoch}.jpg";
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref('detections/$fileName').putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image to Firebase: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera View')),
      body: Stack(
        children: [
          _isCameraInitialized
              ? Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CameraPreview(_controller!),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capture Image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _captureImage,
                      ),
                    ),
                    if (_isUploading)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Uploading Image... Please Wait',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
