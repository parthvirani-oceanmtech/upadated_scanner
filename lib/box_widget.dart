// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;


List<Offset> finalCordinate = [];

class BoxWidget extends StatefulWidget {
  Rect result;

  BoxWidget({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  _BoxWidgetState createState() => _BoxWidgetState();
}

class _BoxWidgetState extends State<BoxWidget> {
  late List<Offset> cornerCordinate;

  @override
  void initState() {
    super.initState();
    // Initialize the corner points based on the recognition result

    initialiseCordinate();
  }

  void initialiseCordinate() {
    final left = widget.result.left;
    final top = widget.result.top;
    final right = widget.result.right;  
    final bottom = widget.result.bottom;

    cornerCordinate = [
      Offset(left, top), // Top left corner
      Offset(right, top), // Top right corner
      Offset(left, bottom), // Bottom left corner
      Offset(right, bottom), // Bottom right corner
    ];

    setState(() {
      finalCordinate = cornerCordinate;
    });
  }

  // void updateFinalCoordinate() {
  //   finalCordinate = [_topLeft, _topRight, _bottomLeft, _bottomRight];

  //   print("Updated coordinates: $finalCordinate");

  //   setState(() {});
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(finalCordinate);
    return Positioned(
      left: 0,
      top: 0,
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ShapePainter(finalCordinate),
            ),
          ),
          Positioned.fill(
            child: ClipPath(
              clipper: ShapeClipper(finalCordinate),
              child: Container(
                color: Colors.transparent, // This is the color of the cropped shape
              ),
            ),
          ),
          // Draggable points at each corner
          for (int i = 0; i < finalCordinate.length; i++)
            Positioned(
              left: finalCordinate[i].dx - 8,
              top: finalCordinate[i].dy - 8,
              child: DraggablePoint(
                onDrag: (Offset offset) {
                  setState(() {
                    finalCordinate[i] += offset;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset> cornerPoints;

  ShapePainter(this.cornerPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red // Color of the lines connecting points
      ..strokeWidth = 2;
    if (cornerPoints.length == 4) {
      canvas.drawLine(cornerPoints[0], cornerPoints[1], paint);
      canvas.drawLine(cornerPoints[1], cornerPoints[3], paint);
      canvas.drawLine(cornerPoints[3], cornerPoints[2], paint);
      canvas.drawLine(cornerPoints[2], cornerPoints[0], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ShapeClipper extends CustomClipper<Path> {
  final List<Offset> cornerPoints;

  ShapeClipper(this.cornerPoints);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(cornerPoints[0].dx, cornerPoints[0].dy);
    for (int i = 1; i < cornerPoints.length; i++) {
      path.lineTo(cornerPoints[i].dx, cornerPoints[i].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class DraggablePoint extends StatelessWidget {
  final Function(Offset) onDrag;

  DraggablePoint({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        onDrag(details.delta);
        print(onDrag);
      },
      child: Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
          color: Colors.red, // Color of the draggable points
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
