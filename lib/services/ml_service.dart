import 'dart:io';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _interpreter;

  // Load the TFLite model from Firebase
  Future<void> loadModel() async {
    try {
      FirebaseCustomModel model = await FirebaseModelDownloader.instance.getModel(
        "TrashDetection",  // Replace with your Firebase model name
        FirebaseModelDownloadType.localModel,
        FirebaseModelDownloadConditions(
          //androidRequireWifi: true,
          iosAllowsCellularAccess: false,
        ),
      );

      String modelPath = model.file.path;
      _interpreter = await Interpreter.fromFile(File(modelPath));
      
      print("✅ TFLite Model Loaded Successfully");
    } catch (e) {
      print("❌ Error loading TFLite Model: $e");
    }
  }

  // Function to run inference
  List<dynamic>? runInference(List<double> input) {
    if (_interpreter == null) {
      print("❌ Model not loaded yet!");
      return null;
    }

    var output = List.filled(1, 0).reshape([1, 1]); // Adjust output shape
    _interpreter!.run(input, output);
    
    return output;
  }
}
