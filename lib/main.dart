// main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/start_page.dart';
import 'pages/guide_page.dart';
import 'pages/manage_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestBluetoothPermissions();
  runApp(PillMateApp());
}

Future<void> requestBluetoothPermissions() async {
  if (await Permission.bluetoothConnect.isDenied ||
      await Permission.bluetoothScan.isDenied ||
      await Permission.location.isDenied) {
    await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location
    ].request();
  }
}

class PillMateApp extends StatelessWidget {
  const PillMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/guide': (context) => GuidePage(),
        '/manage': (context) => ManagePage(
              onBack: () => Navigator.pop(context),
            ),
      },
    );
  }
}
