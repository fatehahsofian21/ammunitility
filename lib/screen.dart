import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageMonitorScreen extends StatelessWidget {
  const StorageMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('STORAGE MONITOR'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('data')
            .doc('latest_state')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final double temperature = data['temperature'] ?? 0.0;
          final double humidity = data['humidity'] ?? 0.0;
          final String status = data['peltier_status'] ?? 'OFF';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular Temperature Dial
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: temperature / 100,
                        strokeWidth: 10,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.orange),
                        backgroundColor: Colors.orange.withOpacity(0.2),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const Text('Temp', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Humidity
                Text(
                  '${humidity.toStringAsFixed(1)}% Humidity',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(height: 20),

                // Peltier Status
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 18,
                    color: status == 'ON' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Power Button (just shows snackbar now)
                IconButton(
                  icon: const Icon(Icons.power_settings_new),
                  iconSize: 50,
                  color: Colors.redAccent,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status: $status')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}