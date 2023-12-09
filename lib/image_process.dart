// ignore_for_file: must_be_immutable, unused_import, unused_local_variable, unnecessary_null_comparison, prefer_const_constructors, unnecessary_brace_in_string_interps, avoid_print

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:upadated_scanner/box_widget.dart';
import 'package:upadated_scanner/draw_page.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import 'package:upadated_scanner/straighten_Image.dart';
import 'package:upadated_scanner/straighten_image_new.dart';

class ImageProcessScreen extends StatefulWidget {
  final XFile imageFile;
  // final List<Recognition>? results;

  Rect rect;

  ImageProcessScreen({super.key, required this.imageFile, required this.rect});

  @override
  State<ImageProcessScreen> createState() => _ImageProcessScreenState();
}

class _ImageProcessScreenState extends State<ImageProcessScreen> {
  late List<Offset> cornercordinate;

  @override
  void initState() {
    List<Offset> cornercordinate = finalCordinate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("crop image")),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.file(
              fit: BoxFit.fill,
              File(widget.imageFile.path),
            ),

            // Bounding boxes
            _boundingBoxes(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // final cropImages = await cropImage(File(widget.imageFile.path));

            final Uint8List imageBytes = await widget.imageFile.readAsBytes();

            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StraightenImage(imageBytes: imageBytes),
              ),
            );
          },
          child: const Icon(Icons.crop),
        ),
      ),
    );
  }

  Widget _boundingBoxes() {
    return BoxWidget(result: widget.rect);
  }

  void cropAndSharePDF() async {
    if (widget.rect != null) {
      final generatedPDF = await cropAndgeneratePDF(File(widget.imageFile.path));

      await sharePDF(generatedPDF);
    }
  }

  Future<void> sharePDF(Uint8List generatedPDF) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/scan_doc.pdf';
    final pdfFile = File(filePath);

    // Write the PDF bytes to a file
    await pdfFile.writeAsBytes(generatedPDF);

    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'scan doc PDF',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing: $e');
      }
    }
  }

  Future<Uint8List> cropAndgeneratePDF(File imageFile) async {
    final pdf = pw.Document();

//crop_image

    if (imageFile != null) {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      // final region = results[0];

      if (originalImage != null) {
        final Offset topLeft = finalCordinate[0];
        final Offset topRight = finalCordinate[1];
        final Offset bottomLeft = finalCordinate[2];
        final Offset bottomRight = finalCordinate[3];

        double left = topLeft.dx;
        double top = topLeft.dy;
        double right = topRight.dx;
        double bottom = bottomLeft.dy;

        // Ensure the crop area is within the bounds of the image
        left = left.clamp(0.0, originalImage.width.toDouble());
        top = top.clamp(0.0, originalImage.height.toDouble());
        right = right.clamp(0.0, originalImage.width.toDouble());
        bottom = bottom.clamp(0.0, originalImage.height.toDouble());

        // Calculate width and height of the cropped region
        double width = right - left;
        double height = bottom - top;

        print("========left = ${left} ====top = ${top}");

        img.Image croppedImage = img.copyCrop(
          originalImage,
          x: left.toInt(),
          y: top.toInt(),
          height: height.toInt(),
          width: width.toInt(),
        );

        // generate pdf

        final pdfImage = pw.MemoryImage(img.encodeJpg(croppedImage));
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(pdfImage),
              );
            },
          ),
        );
      }
    }

    final Uint8List pdfBytes = await pdf.save();

    return pdfBytes;
  }

//   Future<Uint8List> cropImage(File imageFile) async {
//     final Uint8List imageBytes = await imageFile.readAsBytes();
//     final originalImage = img.decodeImage(imageBytes);

//     // Image size
//     final double imageWidth = originalImage!.width.toDouble();
//     final double imageHeight = originalImage.height.toDouble();

// // Screen size
//     final double screenWidth = ScreenUtil().screenWidth;
//     final double screenHeight = ScreenUtil().screenHeight;

//     // Get the coordinates from the provided Rect
//     double left = finalCordinate[0].dx;
//     double top = finalCordinate[0].dy;
//     double right = finalCordinate[1].dx;
//     double bottom = finalCordinate[2].dy;

//     print("crop image=====left :${left} ,top :${top} , right:${right} ,bottm: ${bottom}");

//     print("finalCordinate ===== $finalCordinate");

//     // // Ensure the crop area is within the bounds of the image
//     // left = left.clamp(0.0, originalImage!.width.toDouble());
//     // top = top.clamp(0.0, originalImage.height.toDouble());
//     // right = right.clamp(0.0, originalImage.width.toDouble());
//     // bottom = bottom.clamp(0.0, originalImage.height.toDouble());

//     // Map screen coordinates to image coordinates
//     final double imageLeft = (left / screenWidth) * imageWidth;
//     final double imageTop = (top / screenHeight) * imageHeight;
//     final double imageRight = (right / screenWidth) * imageWidth;
//     final double imageBottom = (bottom / screenHeight) * imageHeight;

//     print("image size====${originalImage.width}=======${originalImage.height}");

//     // // Calculate width and height of the cropped region
//     // double width = right - left;
//     // double height = bottom - top;

//     double width = imageRight - imageLeft;
//     double height = imageBottom - imageTop;

//     img.Image croppedImage = img.copyCrop(
//       originalImage,
//       x: imageLeft.toInt(),
//       y: imageTop.toInt(),
//       height: height.toInt(),
//       width: width.toInt(),
//     );

//     Uint8List cropimage = Uint8List.fromList(img.encodeJpg(croppedImage));

//     return cropimage;
//   }

//   Future<Uint8List> cropImage(File imageFile) async {

//     final ByteData data = await rootBundle.load(imageFile.path);
//     final Uint8List bytes = data.buffer.asUint8List();
// print("object object ");
//     ui.Codec codec = await ui.instantiateImageCodec(bytes);
//     ui.FrameInfo fi = await codec.getNextFrame();
//     ui.Image image = fi.image;

//     // Image size
//     final double imageWidth = image.width.toDouble();
//     final double imageHeight = image.height.toDouble();

//     // Screen size or desired output size
//     final double screenWidth = ScreenUtil().screenWidth;
//     final double screenHeight = ScreenUtil().screenHeight;

//     // Get the coordinates from the provided rectangle
//     double left = finalCordinate[0].dx;
//     double top = finalCordinate[0].dy;
//     double right = finalCordinate[1].dx;
//     double bottom = finalCordinate[2].dy;

//     // Map screen coordinates to image coordinates
//     final double imageLeft = (left / screenWidth) * imageWidth;
//     final double imageTop = (top / screenHeight) * imageHeight;
//     final double imageRight = (right / screenWidth) * imageWidth;
//     final double imageBottom = (bottom / screenHeight) * imageHeight;

//     // Calculate width and height of the cropped region
//     double width = imageRight - imageLeft;
//     double height = imageBottom - imageTop;

//     // Create a Paint object to draw the image
//     Paint paint = Paint()..isAntiAlias = false;

//     // Create a canvas to draw the cropped image
//     ui.PictureRecorder recorder = ui.PictureRecorder();
//     Canvas canvas = Canvas(recorder);

//     // Define the destination rectangle where the cropped image will be drawn
//     Rect dstRect = Rect.fromLTWH(0, 0, width, height);

//     // Define the source rectangle to crop from the original image
//     Rect srcRect = Rect.fromLTWH(imageLeft, imageTop, width, height);

//     // Draw the cropped image onto the canvas
//     canvas.drawImageRect(image, srcRect, dstRect, paint);

//     // Convert the canvas recording into an image
//     ui.Image croppedUIImage = await recorder.endRecording().toImage(width.toInt(), height.toInt());
//     ByteData? byteData = await croppedUIImage.toByteData(format: ui.ImageByteFormat.png);

//     // Convert the cropped image byteData to Uint8List
//     Uint8List cropImageUint8List = byteData!.buffer.asUint8List();

//     return cropImageUint8List;
//   }

  // Future<void> cropImageeee(File imageFile) async {
  //   final path = Path();
  //   path.moveTo(finalCordinate[0].dx, finalCordinate[0].dy);
  //   for (int i = 1; i < finalCordinate.length; i++) {
  //     path.lineTo(finalCordinate[i].dx, finalCordinate[i].dy);
  //   }
  //   path.close();

  //   final imageRecorder = ui.PictureRecorder();
  //   final canvas = Canvas(imageRecorder);
  //   canvas.clipPath(path);

  //   final paint = Paint();
  //   canvas.drawImageRect(
  //     imageFile,
  //     Rect.fromLTWH(0, 0, widget.image.width.toDouble(), widget.image.height.toDouble()),
  //     Rect.fromLTWH(0, 0, widget.image.width.toDouble(), widget.image.height.toDouble()),
  //     paint,
  //   );

  //   final croppedImage = await imageRecorder.endRecording().toImage(
  //         widget.result.width.toInt(),
  //         widget.result.height.toInt(),
  //       );
  //   final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);

  //   if (byteData != null) {
  //     // Use byteData to save or display cropped image
  //     // For example: await SomeImageSaver.saveImage(byteData);
  //     // Display cropped image: Image.memory(byteData.buffer.asUint8List());
  //   }
  // }
}
