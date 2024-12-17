import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

import 'custom_appbar.dart';

void main() => runApp(MyApp());

bool isConnected = false; // Global variable
BluetoothDevice? selectedDevice = null;
String selectedDeviceName = 'No Device';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _bluetoothConnection;
  BluetoothDevice? _connectedDevice;

  double baseValue = 0.0;
  double pinceValue = 0.0;
  double leftValue = 0.0;
  double rightValue = 0.0;

  bool isConnecting = false; // New variable to track connection status
Future<void> _openBluetoothConnection(BuildContext context) async {
  try {
    setState(() {
      isConnecting = true; // Set the loading state
    });

    _bluetoothConnection = await BluetoothConnection.toAddress(selectedDevice!.address);
    print("Connected to ${selectedDevice!.name} ${selectedDevice!.address}");

    // Set the global isConnected variable
    isConnected = true;

    // Update the selected device name
    setState(() {
      selectedDeviceName = selectedDevice!.name!;
    });

    // Show green SnackBar when connected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connected to ${selectedDevice!.name}'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    // Handle connection error
    print('Error connecting to the device: $e');
    isConnected = false;

    // Show red SnackBar when connection error occurs
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error connecting to the device'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    // Reset the loading state after connection attempt
    setState(() {
      isConnecting = false;
    });
  }
}

void _closeBluetoothConnection(BuildContext context) {
  setState(() {
    isConnecting = true; // Set the loading state
  });
  if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
    _bluetoothConnection!.finish();
    isConnected = false;

    // Show green SnackBar when disconnected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disconnected from ${selectedDevice!.name}'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );

    // Update the selected device name to 'No Device'
    setState(() {
      selectedDeviceName = 'No Device';
    });
  }
  setState(() {
    isConnecting = false; // Set the loading state
  });
}


Future<void> sendSliderCommands(BuildContext context) async {
  if (_bluetoothConnection != null && _bluetoothConnection!.isConnected) {
    // Prepare your command based on the slider values
    Map<String, int> commandMap = {
      "base": baseValue.toInt(),
      "pince": pinceValue.toInt(),
      "left": leftValue.toInt(),
      "right": rightValue.toInt(),
    };
    print(commandMap);

    // Convert the command to JSON format
    String command = json.encode(commandMap);

    // Send the command to the Bluetooth device
    try {
      _bluetoothConnection!.output.add(Uint8List.fromList(utf8.encode(command + "\r\n")));
      await _bluetoothConnection!.output.allSent;
    } catch (e) {
      // Handle write error
      print('Error writing to the device: $e');
      // Show SnackBar when write error occurs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error writing to the device'),
          duration: Duration(seconds: 2), backgroundColor: Colors.red,
        ),
      );
    }
  } else {
    print('Bluetooth connection is not established or has been closed.');
    // Show SnackBar when not connected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bluetooth connection is not established or has been closed.'),
        duration: Duration(seconds: 2), backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bluetooth Arm Robot App',
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20),
              Image.asset(
                'assets/robot.png',
                width: 200.0,
                height: 200.0,
              ),
              SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Sliders for control
                  buildSlider("Base", baseValue, (value) {
                    setState(() {
                      baseValue = value;
                    });
                  }),
                  buildSlider("Pince", pinceValue, (value) {
                    setState(() {
                      pinceValue = value;
                    });
                  }),
                  buildSlider("Left", leftValue, (value) {
                    setState(() {
                      leftValue = value;
                    });
                  }),
                  buildSlider("Right", rightValue, (value) {
                    setState(() {
                      rightValue = value;
                    });
                  }),
                  SizedBox(height: 20),
                  Text('Selected Device: $selectedDeviceName', style: TextStyle(fontSize: 18)),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    sendSliderCommands(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('Send'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(visible: !isConnected && !isConnecting,
            child: FloatingActionButton(
              heroTag: 'connectButton',
              onPressed: () async {
                await _navigateToBluetoothPage();
                // If the Bluetooth connection was successful, store the connected device
                 
                  setState(() {
                    _connectedDevice = selectedDevice;
                    selectedDeviceName = selectedDevice!.name!;
                  });
                  _openBluetoothConnection(context);
                
              },
              backgroundColor: Color.fromARGB(255, 33, 68, 243),
              child:  Icon(Icons.bluetooth),
            ),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'shutdownButton',
            onPressed: () {
              if (selectedDevice != null) {
                if (isConnected) {
                  _closeBluetoothConnection(context);
                } else {
                  _openBluetoothConnection(context);
                }
              }
            },
            backgroundColor: isConnected ? Colors.green : Colors.red,
            child: isConnecting
                ? CircularProgressIndicator(color: Colors.white,)
                :Icon(Icons.power_settings_new),
          ),
        ],
      ),
    );
  }

  Widget buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text('$label: ${value.toStringAsFixed(2)}°'),
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: 180,
        ),
      ],
    );
  }

  Future<void> _navigateToBluetoothPage() async {
    selectedDevice = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => BluetoothPage(),
      ),
    );
  }
}

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
    _checkAndStartScan();
  }

  Future<void> _checkAndStartScan() async {
    // Check Bluetooth permissions
    if (await Permission.bluetooth.isGranted && await Permission.bluetoothScan.isGranted) {
      // Permissions granted, start scanning
      _startScan();
    } else {
      // Permissions denied, request them
      await _requestBluetoothPermissions();
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    // Request Bluetooth permissions
    Map<Permission, PermissionStatus> status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
    ].request();

    // Check if permissions were granted
    if (status[Permission.bluetooth] == PermissionStatus.granted &&
        status[Permission.bluetoothScan] == PermissionStatus.granted) {
      // Permissions granted, start scanning
      _startScan();
    } else {
      // Permissions denied, handle accordingly
      print('Bluetooth permissions denied');
    }
  }

  Future<void> _refreshScan() async {
    // Clear the current list of devices
    setState(() {
      devices.clear();
      selectedDevice = null; // Reset selectedDevice
    });

    // Start a new scan
    await _startScan();
  }

  Future<void> _startScan() async {
    // Start scanning for classic Bluetooth devices
    _bluetooth.startDiscovery().listen((BluetoothDiscoveryResult result) {
      if (!devices.contains(result.device)) {
        setState(() {
          devices.add(result.device);
        });
      }
    });
  }

  Future<void> _connectToDevice() async {
    Navigator.pop(context, selectedDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bluetooth Devices',
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = devices[index];
                String? deviceName = device.name?.trim(); // Remove leading/trailing spaces
                String? displayName = deviceName?.isNotEmpty ?? false
                    ? deviceName
                    : 'Unknown Device';
                String macAddress = device.address; // Use the device's MAC address

                return ListTile(
                  title: Text('$displayName\n$macAddress'),
                  onTap: () {
                    setState(() {
                      selectedDevice = devices[index];
                    });
                  },
                  selected: selectedDevice == devices[index],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                _connectToDevice();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Connect'),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _refreshScan();
        },
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
