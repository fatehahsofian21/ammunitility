import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LatestDataWidget extends StatelessWidget {
  const LatestDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No data available.');
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        // Handle timestamp (Firestore Timestamp or string fallback)
        String formattedTimestamp = 'Unknown';
        final ts = data['timestamp'];
        if (ts is Timestamp) {
          formattedTimestamp =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(ts.toDate());
        } else if (ts is String) {
          formattedTimestamp = ts;
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Humidity: ${data['humidity'] ?? '-'}'),
                Text('Peltier Status: ${data['peltier_status'] ?? '-'}'),
                Text('System State: ${data['system_state'] ?? '-'}'),
                Text('Temperature: ${data['temperature'] ?? '-'}'),
                Text('Timestamp: $formattedTimestamp'),
              ],
            ),
          ),
        );
      },
    );
  }
}

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