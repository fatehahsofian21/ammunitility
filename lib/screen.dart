import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageMonitorScreen extends StatefulWidget {
  const StorageMonitorScreen({super.key});

  @override
  State<StorageMonitorScreen> createState() => _StorageMonitorScreenState();
}

class _StorageMonitorScreenState extends State<StorageMonitorScreen> {
  String systemState = 'OFF';
  double temperature = 0.0;
  String peltierStatus = 'OFF';

  @override
  void initState() {
    super.initState();
    _listenToSystemControl();
    _listenToLatestData();
  }

  void _listenToSystemControl() {
    FirebaseFirestore.instance
        .collection('events')
        .doc('system_control')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          systemState = data['system_state'] ?? 'OFF';
        });
      }
    });
  }

  void _listenToLatestData() {
    FirebaseFirestore.instance
        .collection('data')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final latest = snapshot.docs.first.data();
        setState(() {
          temperature = latest['temperature']?.toDouble() ?? 0.0;
          peltierStatus = latest['peltier_status'] ?? 'OFF';
        });
      }
    });
  }

  Future<void> _toggleSystemState() async {
    final bool turningOff = systemState == 'ON';

    if (turningOff && peltierStatus == 'ON') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
              'The Peltier device is currently active. Are you sure you want to turn off the system?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Turn Off'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    final newState = systemState == 'ON' ? 'OFF' : 'ON';

    await FirebaseFirestore.instance
        .collection('events')
        .doc('system_control')
        .set({'system_state': newState});

    setState(() {
      systemState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOn = systemState == 'ON';
    final Color buttonColor = isOn ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: const Color(0xFF3E2D28), // dark brown
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'STORAGE MONITOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (isOn)
                  Column(
                    children: [
                      Text(
                        '${temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Temperature',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  )
                else
                  const Center(
                    child: Text(
                      'System OFF',
                      style: TextStyle(color: Colors.white70, fontSize: 22),
                    ),
                  ),
                const Spacer(),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EDEB), // light brown
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: _toggleSystemState,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.power_settings_new,
                          size: 34,
                          color: buttonColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
