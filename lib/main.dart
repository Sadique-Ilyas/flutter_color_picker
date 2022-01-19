import 'package:flutter/material.dart';
import 'package:flutter_color_picker/ConnectDevice.dart';
import 'package:flutter_color_picker/FlutterCircleColorPicker.dart';
import 'package:flutter_color_picker/FlutterCircleColorPickerController.dart';
import 'package:get/get.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: ConnectDevicePage()
    );
  }
}
