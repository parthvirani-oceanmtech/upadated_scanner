import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:upadated_scanner/image_process.dart';
import 'package:upadated_scanner/object_detection.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ObjectDetection objectDetection = ObjectDetection();

  late List<CameraDescription> cameras;

  // /// Controller
  // CameraController? _cameraController;

  // // use only when initialized, so - not null
  // get _controller => _cameraController;

  // @override
  // void initState() {
  //   initializeCamera();

  //   super.initState();
  // }

  // void initializeCamera() async {
  //   cameras = await availableCameras();

  //   // setState(() {});
  //   // cameras[0] for back-camera
  //   _cameraController = CameraController(
  //     cameras[0],
  //     ResolutionPreset.high,
  //     enableAudio: false,
  //   );

  //    _cameraController!.initialize();
  // }

  // Future<void> _processImage(String imagePath) async {
  //   Uint8List modifiedImage = objectDetection!.analyseImage(imagePath);
  //   setState(() {
  //     image = modifiedImage;
  //   });
  // }
  late CameraController controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    initialisedCamera();
  }

  initialisedCamera() async {
    _cameras = await availableCameras();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Scaffold(
      body: CameraPreview(controller),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () async {
          XFile imageFile = await controller.takePicture();

          // final List<Offset> finalCordinate   =  objectDetection!.boundingBox(imageFile.path);

          Rect rect = objectDetection.detectBoundingBox(imageFile.path);

          print("rect ==========$rect");

          // ignore: use_build_context_synchronously
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageProcessScreen(imageFile: imageFile, rect: rect),
            ),
          );
        },
      ),
    );

    //   return SafeArea(
    //     child: Column(
    //       children: [
    //         Expanded(
    //           child: CameraPreview(_controller),
    //         ),
    //         Align(
    //           alignment: Alignment.bottomCenter,
    //           child: Container(
    //             width: double.infinity,
    //             height: 100,
    //             color: Colors.white.withAlpha(150),
    //             child: Padding(
    //               padding: const EdgeInsets.all(16.0),
    //               child: FloatingActionButton(
    //                 onPressed: () async {
    //                   XFile imageFile = await _controller.takePicture();

    //                   // final List<Offset> finalCordinate   =  objectDetection!.boundingBox(imageFile.path);

    //                   List<Recognition> recognitions = objectDetection!.detectBoundingBox(imageFile.path);

    //                   if (recognitions.isNotEmpty) {
    //                     // ignore: use_build_context_synchronously
    //                     await Navigator.push(
    //                       context,
    //                       MaterialPageRoute(
    //                         builder: (context) =>
    //                             ImageProcess(imageFile: imageFile, controller: _controller, recognitions: recognitions),
    //                       ),
    //                     );
    //                   }
    //                 },
    //                 child: const Icon(Icons.camera),
    //               ),
    //             ),
    //           ),
    //         )
    //       ],
    //     ),
    //   );
    // }
  }
}
