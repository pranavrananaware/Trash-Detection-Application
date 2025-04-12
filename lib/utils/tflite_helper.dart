// import 'dart:typed_data';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'json_loader.dart';

// class TFLiteHelper {
//   late Interpreter _interpreter;
//   late Map<String, dynamic> modelJson;

//   Future<void> loadModel() async {
//     modelJson = await JsonLoader.loadModelJson(); // Load JSON
//     _interpreter = await Interpreter.fromAddress(modelJson['interpreter_address']);
//     print("TFLite Model Loaded Successfully!");
//   }

//   List<dynamic> runModel(Uint8List imageBytes) {
//     var input = [imageBytes]; // Prepare input data
//     var output = List.generate(1, (index) => List.filled(10, 0)); // Adjust based on model output

//     _interpreter.run(input, output);
//     return output;
//   }
// }
