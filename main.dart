import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('BLE Scanner'),
        ),
        body: BleScanner(),
      ),
    );
  }
}

class BleScanner extends StatefulWidget {
  @override
  _BleScannerState createState() => _BleScannerState();
}

class _BleScannerState extends State<BleScanner> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = List<BluetoothDevice>();

  @override
  void initState() {
    super.initState();
    startScan();
  }

  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        setState(() {
          devicesList.add(r.device);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devicesList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(devicesList[index].name),
          onTap: () async {
            await devicesList[index].connect();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeviceScreen(device: devicesList[index])),
            );
          },
        );
      },
    );
  }
}

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;

  DeviceScreen({Key key, this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device: ${device.name}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            List<BluetoothService> services = await device.discoverServices();
            BluetoothCharacteristic characteristic = services[0].characteristics[0];
            await characteristic.write(utf8.encode("Hello World"));
          },
          child: Text('Send Data'),
        ),
      ),
    );
  }
}
