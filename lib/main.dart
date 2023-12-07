import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:upadated_scanner/my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}



//  double left = recognition[0].location.left;
//         double top = recognition[0].location.top;
//         double right = recognition[0].location.right;
//         double bottom = recognition[0].location.bottom;


//         // Ensure the crop area is within the bounds of the image
//         left = left.clamp(0.0, originalImage.width.toDouble());
//         top = top.clamp(0.0, originalImage.height.toDouble());
//         right = right.clamp(0.0, originalImage.width.toDouble());
//         bottom = bottom.clamp(0.0, originalImage.height.toDouble());


//         // Calculate width and height of the cropped region
//         double width = right - left;
//         double height = bottom - top;
