// ignore_for_file: unused_local_variable, prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:upadated_scanner/box_widget.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class StraightenImage extends StatefulWidget {
  final Uint8List imageBytes;

  const StraightenImage({super.key, required this.imageBytes});

  @override
  State<StraightenImage> createState() => _StraightenImageState();
}

class _StraightenImageState extends State<StraightenImage> {
  final List<Offset> cropCoordinates = [
    finalCordinate[0],
    finalCordinate[1],
    finalCordinate[3],
    finalCordinate[2],
  ];

  final Size screenSize = Size(ScreenUtil().screenWidth, ScreenUtil().screenHeight);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(cropCoordinates);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Cropped Image Display'),
      ),
      body: SizedBox(
        width: ScreenUtil().screenWidth,
        height: ScreenUtil().screenHeight,
        child: ClipPath(
          clipper: CustomShapeClipper(finalCordinate),
          child: Align(
            alignment: Alignment.topLeft,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(0, 0, 1.0) // Scale factor
                ..setEntry(0, 1, 0.0) // Shear factor
                ..setEntry(1, 0, 0.0) // Shear factor
                ..setEntry(1, 1, 1.0) // Scale factor
                ..setEntry(3, 2, 0.001), // Perspective coefficient calculateTransformMatrix(),
              child: Image.memory(
                widget.imageBytes,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Matrix4 calculateTransformMatrix() {
    Offset topLeft = finalCordinate[0];
    Offset topRight = finalCordinate[1];
    Offset bottomLeft = finalCordinate[3];

    vector.Vector3 cropTopLeft = vector.Vector3(topLeft.dx, topLeft.dy, 0);
    vector.Vector3 cropTopRight = vector.Vector3(topRight.dx, topRight.dy, 0);
    vector.Vector3 cropBottomLeft = vector.Vector3(bottomLeft.dx, bottomLeft.dy, 0);

    vector.Vector3 screenTopLeft = vector.Vector3(0, 0, 0);
    vector.Vector3 screenTopRight = vector.Vector3(ScreenUtil().screenWidth, 0, 0);
    vector.Vector3 screenBottomLeft = vector.Vector3(0, ScreenUtil().screenHeight, 0);

    vector.Vector3 xBasis = (screenTopRight - screenTopLeft).normalized();
    vector.Vector3 yBasis = (screenBottomLeft - screenTopLeft).normalized();
    vector.Vector3 zBasis = xBasis.cross(yBasis).normalized();

    vector.Matrix4 transformationMatrix = vector.Matrix4(
      xBasis.x,
      yBasis.x,
      zBasis.x,
      0,
      xBasis.y,
      yBasis.y,
      zBasis.y,
      0,
      xBasis.z,
      yBasis.z,
      zBasis.z,
      0,
      0,
      0,
      0,
      1,
    );

    return transformationMatrix;
  }
}

// class CropPainter extends CustomPainter {
//   final List<Offset> coordinates;
//   final Uint8List imageBytes;

//   CropPainter(this.coordinates, this.imageBytes);

//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()..isAntiAlias = true;
//     Path path = Path()..addPolygon(coordinates, true);

//     canvas.clipPath(path);

//     // Calculate transformation matrix
//     Matrix4 transformMatrix = calculateTransformMatrix(size);

//     // Apply transformation matrix to draw the cropped image
//     canvas.transform(transformMatrix.storage);
//     drawImage(canvas, size);
//   }
//     void drawImage(Canvas canvas, Size size) async {
//     ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
//     ui.Image image = (await codec.getNextFrame()).image;

//     canvas.drawImageRect(
//       image,
//       Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       Paint(),
//     );
//   }

//   Matrix4 calculateTransformMatrix(Size size) {
//     // Calculate transformation matrix based on screen and crop coordinates
//     Offset topLeft = coordinates[0];
//     Offset topRight = coordinates[1];
//     Offset bottomLeft = coordinates[3];

//     vector.Vector3 cropTopLeft = vector.Vector3(topLeft.dx, topLeft.dy, 0);
//     vector.Vector3 cropTopRight = vector.Vector3(topRight.dx, topRight.dy, 0);
//     vector.Vector3 cropBottomLeft = vector.Vector3(bottomLeft.dx, bottomLeft.dy, 0);

//     vector.Vector3 screenTopLeft = vector.Vector3(0, 0, 0);
//     vector.Vector3 screenTopRight = vector.Vector3(size.width, 0, 0);
//     vector.Vector3 screenBottomLeft = vector.Vector3(0, size.height, 0);

//     vector.Vector3 xBasis = (screenTopRight - screenTopLeft).normalized();
//     vector.Vector3 yBasis = (screenBottomLeft - screenTopLeft).normalized();
//     vector.Vector3 zBasis = xBasis.cross(yBasis).normalized();

//     vector.Matrix4 transformationMatrix = vector.Matrix4(
//       xBasis.x,
//       yBasis.x,
//       zBasis.x,
//       0,
//       xBasis.y,
//       yBasis.y,
//       zBasis.y,
//       0,
//       xBasis.z,
//       yBasis.z,
//       zBasis.z,
//       0,
//       0,
//       0,
//       0,
//       1,
//     );

//     vector.Matrix4 scalingMatrix = vector.Matrix4.identity()
//       ..scale(
//         screenTopRight.distanceTo(screenTopLeft) / cropTopRight.distanceTo(cropTopLeft),
//         screenBottomLeft.distanceTo(screenTopLeft) / cropBottomLeft.distanceTo(cropTopLeft),
//         1,
//       );

//     transformationMatrix.multiply(scalingMatrix);

//     return Matrix4.fromFloat64List(transformationMatrix.storage);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }

// Matrix4 calculateTransformMatrix() {
//   // Calculate scaling factors
//   double scaleX = screenSize.width / ScreenUtil().screenWidth;
//   double scaleY = screenSize.height / ScreenUtil().screenHeight;

//   // Calculate translation factors
//   double translateX = finalCordinate[0].dx * scaleX;
//   double translateY = finalCordinate[0].dy * scaleY;

//   // Create and return the transformation matrix
//   return Matrix4.identity()
//     ..translate(translateX, translateY)
//     ..scale(scaleX, scaleY);
// }

class ImagePainter extends CustomPainter {
  final List<Offset> points;

  ImagePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw lines connecting the transformed points
    Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.lineTo(points[0].dx, points[0].dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
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






// Matrix4 calculateTransformMatrix(Size size) {
//   // Calculate transformation matrix based on screen and crop coordinates
//   Offset topLeft = coordinates[0];
//   Offset topRight = coordinates[1];
//   Offset bottomLeft = coordinates[3];

//   vector.Vector3 cropTopLeft = vector.Vector3(topLeft.dx, topLeft.dy, 0);
//   vector.Vector3 cropTopRight = vector.Vector3(topRight.dx, topRight.dy, 0);
//   vector.Vector3 cropBottomLeft = vector.Vector3(bottomLeft.dx, bottomLeft.dy, 0);

//   vector.Vector3 screenTopLeft = vector.Vector3(0, 0, 0);
//   vector.Vector3 screenTopRight = vector.Vector3(size.width, 0, 0);
//   vector.Vector3 screenBottomLeft = vector.Vector3(0, size.height, 0);

//   vector.Vector3 xBasis = (screenTopRight - screenTopLeft).normalized();
//   vector.Vector3 yBasis = (screenBottomLeft - screenTopLeft).normalized();
//   vector.Vector3 zBasis = xBasis.cross(yBasis).normalized();

//   vector.Matrix4 transformationMatrix = vector.Matrix4(
//     xBasis.x,
//     yBasis.x,
//     zBasis.x,
//     0,
//     xBasis.y,
//     yBasis.y,
//     zBasis.y,
//     0,
//     xBasis.z,
//     yBasis.z,
//     zBasis.z,
//     0,
//     0,
//     0,
//     0,
//     1,
//   );

//   vector.Matrix4 scalingMatrix = vector.Matrix4.identity()
//     ..scale(
//       screenTopRight.distanceTo(screenTopLeft) / cropTopRight.distanceTo(cropTopLeft),
//       screenBottomLeft.distanceTo(screenTopLeft) / cropBottomLeft.distanceTo(cropTopLeft),
//       1,
//     );

//   transformationMatrix.multiply(scalingMatrix);

//   return Matrix4.fromFloat64List(transformationMatrix.storage);
// }
