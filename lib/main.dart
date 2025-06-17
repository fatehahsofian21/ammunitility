import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screen.dart'; // Make sure screen.dart is in the same folder

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StorageMonitorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
