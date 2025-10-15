// widgets/bluetooth_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';

class BluetoothModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(BluetoothDevice) onConnected;

  const BluetoothModal({super.key, required this.onClose, required this.onConnected});

   @override
  _BluetoothModalState createState() => _BluetoothModalState();
}


class _BluetoothModalState extends State<BluetoothModal> {
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? connectedDevice;
  BluetoothConnection? connection;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    scanDevices();
  }

  void scanDevices() async {
    bool isEnabled = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    if (!isEnabled) await FlutterBluetoothSerial.instance.requestEnable();

    List<BluetoothDevice> bondedDevices =
        await FlutterBluetoothSerial.instance.getBondedDevices();

    setState(() => devicesList = bondedDevices);
  }
void connectToDevice(BluetoothDevice device) async {
  setState(() => isConnecting = true);
  try {
    connection = await BluetoothConnection.toAddress(device.address);
    setState(() => isConnecting = false);
    widget.onConnected(device); // 연결 성공 알림

    connection!.input!.listen((data) {
      final received = String.fromCharCodes(data);
      print('Received: $received');
    }).onDone(() {
      print('Disconnected by remote request');
      setState(() => connectedDevice = null);
    });
  } catch (e) {
    print('Cannot connect: $e');
    setState(() => isConnecting = false);
  }
}


  void sendData(String message) {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Uint8List.fromList(message.codeUnits));
      connection!.output.allSent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 400,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text("블루투스 장치 선택", style: TextStyle(fontWeight: FontWeight.bold))),
                IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close))
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  final device = devicesList[index];
                  return ListTile(
                    title: Text(device.name ?? "Unknown"),
                    subtitle: Text(device.address),
                    trailing: ElevatedButton(
                      onPressed: connectedDevice == null
                          ? () => connectToDevice(device)
                          : null,
                      child: Text(
                        isConnecting ? "연결 중..." : (connectedDevice == device ? "연결됨" : "연결"),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (connectedDevice != null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (v) => sendData(v),
                      decoration: const InputDecoration(
                        hintText: "데이터 입력 후 Enter",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => sendData("PING"), child: const Text("전송")),
                ],
              )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }
}
