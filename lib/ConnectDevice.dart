import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_color_picker/FlutterCircleColorPicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ConnectDevicePage extends StatefulWidget {
  const ConnectDevicePage({Key? key}) : super(key: key);

  @override
  _ConnectDevicePageState createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection? connection;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => (connection?.isConnected ?? false);
  // This member variable will be used for tracking
  // the Bluetooth device connection state
  late int _deviceState;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // _deviceState = 0; // neutral

    if (_bluetoothState == BluetoothState.STATE_OFF) {
      _devicesList.clear();
    } else {
      getPairedDevices();
    }

    // If the Bluetooth of the device is not enabled,
    // then request permission to turn on Bluetooth
    // as the app starts up
    // enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // For retrieving the paired devices list
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _devicesList.clear();
        } else {
          getPairedDevices();
        }
      });
    });
  }

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await _bluetooth.state;

    // If the Bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      try {
        await FlutterBluetoothSerial.instance.requestEnable();
      } on Exception catch (e) {
        e.printError();
      }
      await getPairedDevices();
    } else {
      await getPairedDevices();
    }
  }

  // Define a new class member variable
// for storing the devices list
  List<BluetoothDevice> _devicesList = [];

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

// Define a member variable to track
// when the disconnection is in progress
  bool isDisconnecting = false;

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection?.close();
    }

    super.dispose();
  }

  // Define this member variable for storing
  // the current device connectivity status
  bool _connected = false;

  // Define this member variable for storing
  // each device from the bottomsheet items
  late BluetoothDevice _device;

  // Connect to Paired Device
  void _connectToDevice(BluetoothDevice device) async {
    _device = device;
    Fluttertoast.showToast(msg: device.address);
    if (!isConnected) {
      // Trying to connect to the device using
      // its address
      try {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          Get.back();
          Fluttertoast.showToast(msg: 'Connected to ${_device.name}');
          connection = _connection;

          // Updating the device connectivity
          // status to [true]
          setState(() {
            _connected = true;
          });

          Get.to(() => ColorPicker(), arguments: connection);

          // This is for tracking when the disconnecting process
          // is in progress which uses the [isDisconnecting] variable
          // defined before.
          // Whenever we make a disconnection call, this [onDone]
          // method is fired.
          connection!.input!.listen(null).onDone(() {
            if (isDisconnecting) {
              _connected = false;
              Fluttertoast.showToast(msg: 'Disconnecting locally!');
              print('Disconnecting locally!');
            } else {
              _connected = false;
              Fluttertoast.showToast(msg: 'Disconnected remotely!');
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        });
      } on PlatformException catch (e) {
        print(e.code);
        Fluttertoast.showToast(msg: e.code);
      }
    }
  }

  // Inside _BluetoothAppState class

  void _disconnectFromDevice() async {
    // Closing the Bluetooth connection
    await connection?.close();

    Fluttertoast.showToast(msg: 'Device disconnected');

    // Update the [_connected] variable
    if (!(connection!.isConnected)) {
      setState(() {
        _connected = false;
      });
    }
  }

  int _connectionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue, Colors.black],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: _bluetoothState == BluetoothState.STATE_OFF
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Bluetooth State: ${_bluetoothState.stringValue}'),
                          Text('Turn On Bluetooth and Pair Device: '),
                          ElevatedButton(
                            onPressed: () {
                              _bluetooth.openSettings();
                            },
                            child: Text('Turn On'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Bluetooth State: ${_bluetoothState.stringValue}'),
                          Text('Turn Off Bluetooth: '),
                          ElevatedButton(
                            onPressed: () {
                              _bluetooth.openSettings();
                            },
                            child: Text('Turn Off'),
                          ),
                        ],
                      ),
              ),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(16),
                    shadowColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(CircleBorder()),
                    overlayColor: MaterialStateProperty.all(Colors.white38),
                    padding: MaterialStateProperty.all(EdgeInsets.all(70))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connect',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    Text('to Paired Device'),
                  ],
                ),
                onPressed: () {
                  showBottomSheets();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  showBottomSheets() async {
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.white70, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                height: 50,
                child: IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down_sharp,
                      size: 35,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Get.back();
                    })),
            Text(
              _devicesList.isEmpty ? 'Turn On Bluetooth' : 'Paired Devices',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _devicesList[index].name ?? "Unknown",
                        style: TextStyle(color: Colors.black),
                      ),
                      leading: Icon(
                        Icons.bluetooth,
                        color: Colors.black,
                      ),
                      trailing: _connected
                          ? _connectionIndex == index
                              ? Icon(Icons.cancel)
                              : Icon(Icons.link, color: Colors.black)
                          : Icon(Icons.link, color: Colors.black),
                      onTap: () {
                        _connectionIndex = index;
                        if (_connected) {
                          _disconnectFromDevice();
                        } else {
                          _connectToDevice(_devicesList[index]);
                        }
                      },
                    );
                  },
                  itemCount: _devicesList.length),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      barrierColor: Colors.transparent,
    );
  }
}
