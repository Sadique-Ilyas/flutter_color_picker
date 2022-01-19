import 'package:flutter/material.dart';
import 'package:flutter_color_picker/ConnectDevice.dart';
import 'package:flutter_color_picker/FlutterCircleColorPickerController.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({Key? key}) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  Color _currentColor = Colors.blue;
  final _controller = CircleColorPickerController(
    initialColor: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _currentColor,
        title: const Text('Circle color picker sample'),
        actions: [
          ElevatedButton(onPressed: () {}, child: Text('Disconnect'))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 48),
          Center(
            child: CircleColorPicker(
              controller: _controller,
              onChanged: (color) {
                setState(() => _currentColor = color);
              },
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  TextButton(
                    onPressed: () => _controller.color = Colors.red,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                  ),
                  Text(
                    'R',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () =>
                        _controller.color = Color.fromARGB(255, 0, 255, 0),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 0, 255, 0)),
                    ),
                  ),
                  Text(
                    'G',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () => _controller.color = Colors.blue,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                    ),
                  ),
                  Text(
                    'B',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
