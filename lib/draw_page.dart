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

    final Offset topLeft = finalCordinate[0];
    final Offset topRight = finalCordinate[1];
    final Offset bottomLeft = finalCordinate[2];
    final Offset bottomRight = finalCordinate[3];

    double left = topLeft.dx;
    double top = topLeft.dy;
    double right = topRight.dx;
    double bottom = bottomLeft.dy;

    // Calculate width and height of the cropped region
    double width = right - left;
    double height = bottom - top;

    final croppedImage = img.copyCrop(
      rawImage!,
      x: left.toInt(),
      y: top.toInt(),
      width: width.toInt(),
      height: height.toInt(),
    );

    final croppedBytes = img.encodePng(croppedImage);

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

// Matrix4 _calculateTransformMatrix(BuildContext context) {
//   final Size imageSize = Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
//   final Size screenSize = MediaQuery.of(context).size;

//   final List<Offset> coordinates = finalCordinate;

//   final double x1 = coordinates[0].dx;
//   final double y1 = coordinates[0].dy;
//   final double x2 = coordinates[1].dx;
//   final double y2 = coordinates[1].dy;
//   final double x3 = coordinates[2].dx;
//   final double y3 = coordinates[2].dy;
//   final double x4 = coordinates[3].dx;
//   final double y4 = coordinates[3].dy;

//   final double minX = [x1, x2, x3, x4].reduce((value, element) => value > element ? element : value);
//   final double maxX = [x1, x2, x3, x4].reduce((value, element) => value < element ? element : value);
//   final double minY = [y1, y2, y3, y4].reduce((value, element) => value > element ? element : value);
//   final double maxY = [y1, y2, y3, y4].reduce((value, element) => value < element ? element : value);

//   final Matrix4 matrix = Matrix4.identity();

//   matrix.setEntry(0, 0, (maxX - minX) / imageSize.width);
//   matrix.setEntry(1, 1, (maxY - minY) / imageSize.height);
//   matrix.setEntry(3, 0, minX);
//   matrix.setEntry(3, 1, minY);

//   return matrix;
// }

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
