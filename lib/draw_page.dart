// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:upadated_scanner/box_widget.dart';
import 'package:image/image.dart' as img;

class DrawPage extends StatefulWidget {
  final Uint8List imageBytes;
  DrawPage({required this.imageBytes});

  // Uint8List cropImages;
  // DrawPage({Key? key, required this.cropImages});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  @override
  Widget build(BuildContext context) {
    final rawImage = img.decodeImage(widget.imageBytes);

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Image'),
      ),
      body: ClipPath(
        clipper: CustomShapeClipper(finalCordinate),
        child: Image.memory(
          widget.imageBytes, // Use the image bytes captured from the camera
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// class ImagePainter extends CustomPainter {
//   final Uint8List imageBytes;
//   final List<Offset> finalCoordinate;

//   ImagePainter({required this.imageBytes, required this.finalCoordinate});

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (finalCoordinate.length != 4) return;

//     final double minX = finalCoordinate.map((e) => e.dx).reduce((a, b) => a < b ? a : b);
//     final double minY = finalCoordinate.map((e) => e.dy).reduce((a, b) => a < b ? a : b);
//     final double maxX = finalCoordinate.map((e) => e.dx).reduce((a, b) => a > b ? a : b);
//     final double maxY = finalCoordinate.map((e) => e.dy).reduce((a, b) => a > b ? a : b);

//     final originalImage = img.decodeImage(imageBytes);

//     // Image size
//     final double imageWidth = originalImage!.width.toDouble();
//     final double imageHeight = originalImage.height.toDouble();

//     final Rect destinationRect = Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
//     final Rect sourceRect = Rect.fromLTWH(0, 0, imageWidth, imageHeight);

//     // canvas.drawImageRect(
//     //   // Adjust the Rectangles for the image size and position
//     //   // Draw image with calculated coordinates
//     //   Image.memory(imageBytes).image,
//     //   sourceRect,
//     //   destinationRect,
//     //   Paint(),
//     // );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }

Matrix4 _calculateTransformMatrix(
    {required double screenWidth,
    required double screenHeight,
    required BuildContext context,
    required double cropWidth,
    required double cropHeight}) {
  // final Size imageSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
  // final Size screenSize = MediaQuery.of(context).size;

  final List<Offset> originalCorners = [
    const Offset(0, 0), // Top-left corner of the original image
    Offset(screenWidth, 0), // Top-right corner
    Offset(0, screenHeight), // Bottom-left corner
    Offset(screenWidth, screenHeight), // Bottom-right corner
  ];

  // Define the desired transformed corners based on the user-selected corners
  final List<Offset> targetCorners = finalCordinate; // Assuming the user provides the corners

  final List<Offset> src = [
    originalCorners[0],
    originalCorners[1],
    originalCorners[2],
    originalCorners[3],
  ];

  // Target corners: desired positions after transformation
  final List<Offset> dst = [
    targetCorners[0],
    targetCorners[1],
    targetCorners[2],
    targetCorners[3],
  ];

  // Construct transformation matrix
  final srcMatrix = _constructMatrix(src);
  final dstMatrix = _constructMatrix(dst);

  final transformationMatrix = srcMatrix * dstMatrix.invert();

  // Create a transformation matrix using Matrix4.identity() as the starting point

  return transformationMatrix;
}

Matrix4 _constructMatrix(List<Offset> corners) {
  final Matrix4 matrix = Matrix4.identity();

  // Assuming that the corners are mapped to a normalized square (0-1 in both dimensions)
  // Mapping the corners to a unit square simplifies the transformation calculation
  matrix.setEntry(0, 0, corners[0].dx);
  matrix.setEntry(0, 1, corners[0].dy);
  matrix.setEntry(0, 3, 1);

  matrix.setEntry(1, 0, corners[1].dx);
  matrix.setEntry(1, 1, corners[1].dy);
  matrix.setEntry(1, 3, 1);

  matrix.setEntry(2, 0, corners[2].dx);
  matrix.setEntry(2, 1, corners[2].dy);
  matrix.setEntry(2, 3, 1);

  matrix.setEntry(3, 0, corners[3].dx);
  matrix.setEntry(3, 1, corners[3].dy);
  matrix.setEntry(3, 3, 1);

  return matrix;
}

class CustomShapeClipper extends CustomClipper<Path> {
  final List<Offset> offsets;

  CustomShapeClipper(this.offsets);

  @override
  Path getClip(Size size) {
    final path = Path();

    if (offsets.isNotEmpty) {
      path.moveTo(offsets[0].dx, offsets[0].dy);

      if (offsets.length == 4) {
        path.lineTo(offsets[1].dx, offsets[1].dy);
        path.lineTo(offsets[3].dx, offsets[3].dy);
        path.lineTo(offsets[2].dx, offsets[2].dy);
        path.close();
      }

      // for (int i = 1; i < offsets.length; i++) {
      //   path.lineTo(offsets[i].dx, offsets[i].dy);
      // }
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}





//  finalCordinate = [_topLeft, _topRight, _bottomLeft, _bottomRight];

// class RectanglePainter extends CustomPainter {
//   final Offset topLeft;
//   final Offset topRight;
//   final Offset bottomLeft;
//   final Offset bottomRight;

//   RectanglePainter(this.topLeft, this.topRight, this.bottomLeft, this.bottomRight);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;

//     // Draw lines between Offsets to form the rectangle
//     canvas.drawLine(topLeft, topRight, paint);
//     canvas.drawLine(topRight, bottomRight, paint);
//     canvas.drawLine(bottomRight, bottomLeft, paint);
//     canvas.drawLine(bottomLeft, topLeft, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
