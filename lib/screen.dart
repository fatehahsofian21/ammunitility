import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageMonitorScreen extends StatefulWidget {
  const StorageMonitorScreen({super.key});

  @override
  State<StorageMonitorScreen> createState() => _StorageMonitorScreenState();
}

class _StorageMonitorScreenState extends State<StorageMonitorScreen> {
  bool isSystemOn = false;
  double temperature = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToSystemState();
    _listenToLatestTemperature();
  }

  void _listenToSystemState() {
    FirebaseFirestore.instance
        .collection('events')
        .doc('system_control')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          isSystemOn = (snapshot.data()?['system_state'] ?? 'OFF') == 'ON';
        });
      }
    });
  }

  void _listenToLatestTemperature() {
    FirebaseFirestore.instance
        .collection('data')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          temperature = (data['temperature'] ?? 0.0).toDouble();
        });
      }
    });
  }

  void _toggleSystemState() async {
    final newState = isSystemOn ? 'OFF' : 'ON';
    await FirebaseFirestore.instance
        .collection('events')
        .doc('system_control')
        .update({'system_state': newState});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A2F2F), // dark brown
      body: Column(
        children: [
          const SizedBox(height: 60), // spacing from top
          const Text(
            'STORAGE MONITOR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 80),
          isSystemOn
              ? Column(
                  children: [
                    Text(
                      '${temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Temperature',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                )
              : const Expanded(
                  child: Center(
                    child: Text(
                      'SYSTEM IS OFF',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          const Spacer(),
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F1F1), // light grey
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: _toggleSystemState,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.power_settings_new,
                    color: isSystemOn ? Colors.green : Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
