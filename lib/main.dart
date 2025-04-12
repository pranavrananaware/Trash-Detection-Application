import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/material.dart';
import 'package:trashhdetection/screens/login_screen.dart';

File? _modelFile; // Store model file path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }

  // Download ML model
  await downloadMLModel();

  runApp(MyApp());
}

// 🔹 Function to Download Model from Firebase ML
Future<void> downloadMLModel() async {
  try {
    // ✅ Firebase automatically manages network settings (WiFi/Mobile)
    FirebaseModelDownloadConditions conditions = FirebaseModelDownloadConditions(
      iosAllowsCellularAccess: false, // Prevents mobile data usage on iOS
    );

    // ✅ Download the model from Firebase ML
    FirebaseCustomModel model = await FirebaseModelDownloader.instance.getModel(
      "TrashDetection", // Replace with your actual model name
      FirebaseModelDownloadType.localModel,
      conditions,
    );

    // ✅ Store model file path for later use
    _modelFile = model.file;
    print("✅ Model downloaded successfully at: ${_modelFile?.path}");
  } catch (e) {
    print("❌ Error downloading ML model: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// 🔹 Splash Screen (Navigates to Login after 2s)
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });

    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.water_damage, // Same icon as login screen
              size: 100.0,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Water Trash Detection',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}