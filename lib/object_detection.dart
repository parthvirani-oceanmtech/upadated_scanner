// ignore_for_file: unnecessary_brace_in_string_interps, avoid_print

/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:upadated_scanner/recognition.dart';

class ObjectDetection {
  static const String _modelPath = 'assets/models/ssd_mobilenet.tflite';
  static const String _labelPath = 'assets/models/labelmap.txt';

  Interpreter? _interpreter;
  List<String>? _labels;

  ObjectDetection() {
    _loadModel();
    _loadLabels();
    log('Done.');
  }

  Future<void> _loadModel() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    // Use Metal Delegate
    if (Platform.isIOS) {
      interpreterOptions.addDelegate(GpuDelegate());
    }

    log('Loading interpreter...');
    _interpreter = await Interpreter.fromAsset(_modelPath, options: interpreterOptions);
  }

  Future<void> _loadLabels() async {
    log('Loading labels...');
    final labelsRaw = await rootBundle.loadString(_labelPath);
    _labels = labelsRaw.split('\n');
  }

  Uint8List analyseImage(String imagePath) {
    log('Analysing image...');
    // Reading image bytes from file
    final imageData = File(imagePath).readAsBytesSync();

    // Decoding image
    final image = img.decodeImage(imageData);

    // Resizing image fpr model, [300, 300]
    final imageInput = img.copyResize(
      image!,
      width: 300,
      height: 300,
    );

    // Creating matrix representation, [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final output = _runInference(imageMatrix);

    log('Processing outputs...');
    // Location
    final locationsRaw = output.first.first as List<List<double>>;

    final List<Rect> locations = locationsRaw
        .map((list) => list.map((value) => (value * 300)).toList())
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();

    // Classes
    final classesRaw = output.elementAt(1).first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();

    // Scores
    final scores = output.elementAt(2).first as List<double>;

    // Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();

    print("xxxxxxxxxxxxxxxxxxxxxxxxx${numberOfDetections}");

    final List<String> classification = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classification.add(_labels![classes[i]]);
    }

    /// Generate recognitions
    List<Recognition> recognitions = [];

    for (int i = 0; i < numberOfDetections; i++) {
      // Prediction score
      var score = scores[i];
      // Label string
      var label = classification[i];

      var boundingBox = locations[i];

      if (score > 0.6) {
        recognitions.add(
          Recognition(i, score, boundingBox, label),
        );
      }
    }
    log('Outlining objects...');
    // for (var i = 0; i < numberOfDetections; i++) {
    //   if (scores[i] > 0.6) {
    //     print(
    //         '==========================>>>>>>>>>Object ${classication[i]} at (${locations[i][1]}, ${locations[i][0]})');
    //     // Rectangle drawing

    //     img.drawRect(
    //       imageInput,
    //       x1: locations[i][1],
    //       y1: locations[i][0],
    //       x2: locations[i][3],
    //       y2: locations[i][2],
    //       color: img.ColorRgb8(255, 0, 0),
    //       thickness: 3,
    //     );

    //     // Label drawing
    //   }
    // }

    log('Done.');

    return img.encodeJpg(imageInput);
  }

  // Future<image_lib.Image?> cropDetectedObject(
  //   image_lib.Image? image,
  //   Rect boundingBox,
  // ) async {
  //   if (image == null) return null;

  //   try {
  //     final croppedImage = image_lib.copyCrop(
  //       image,
  //       x: boundingBox.left.toInt(),
  //       y: boundingBox.top.toInt(),
  //       width: boundingBox.width.toInt(),
  //       height: boundingBox.height.toInt(),
  //     );
  //     return croppedImage;
  //   } catch (e) {
  //     print('Error during cropping: $e');
  //     return null;
  //   }
  // }

  List<List<Object>> _runInference(
    List<List<List<num>>> imageMatrix,
  ) {
    log('Running inference...');

    // Set input tensor [1, 300, 300, 3]
    final input = [imageMatrix];

    // Set output tensor
    // Locations: [1, 10, 4]
    // Classes: [1, 10],
    // Scores: [1, 10],
    // Number of detections: [1]
    final output = {
      0: [List<List<num>>.filled(10, List<num>.filled(4, 0))],
      1: [List<num>.filled(10, 0)],
      2: [List<num>.filled(10, 0)],
      3: [0.0],
    };

    _interpreter!.runForMultipleInputs([input], output);
    return output.values.toList();
  }

  Rect detectBoundingBox(String imagePath) {
    log('Analysing image...');
    // Reading image bytes from file
    final imageData = File(imagePath).readAsBytesSync();

    // Decoding image
    final image = img.decodeImage(imageData);

    // Resizing image fpr model, [300, 300]
    final imageInput = img.copyResize(
      image!,
      width: 300,
      height: 300,
    );

    // Creating matrix representation, [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final output = _runInference(imageMatrix);

    log('Processing outputs...');
    // Location
    final locationsRaw = output.first.first as List<List<double>>;

    final List<Rect> locations = locationsRaw
        .map((list) => list.map((value) => (value * 300)).toList())
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();

    // Classes
    final classesRaw = output.elementAt(1).first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();

    // Scores
    final scores = output.elementAt(2).first as List<double>;

    // Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();

    final List<String> classification = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classification.add(_labels![classes[i]]);
    }

    /// Generate recognitions
    List<Recognition> recognitions = [];

    for (int i = 0; i < numberOfDetections; i++) {
      // Prediction score
      var score = scores[i];
      // Label string
      var label = classification[i];

      var boundingBox = locations[i];

      print("label ======== ${label}");

      // if (label.toLowerCase().contains('book')) {
      //   recognitions.add(
      //     Recognition(i, score, boundingBox, label),
      //   );
      // }

      if (score > 0.60) {
        recognitions.add(
          Recognition(i, score, boundingBox, label),
        );
      }
    }

    print("recognitions========$recognitions");

    // [Offset(39.1, 82.6), Offset(354.0, 85.9), Offset(23.8, 606.8), Offset(361.6, 592.3)]

    if (recognitions.isEmpty) {
      Rect random = const Rect.fromLTRB(50.0, 110.0, 340.0, 592.3);

      return random;
    } else {
      print("recognitions num ===== ${recognitions.length}");
      return recognitions[0].location;
    }
  }

  // List<Offset> boundingBox(String path) {
  //   return [topLeft, topRight, bottomRight, bottomLeft];
  // }
}
