import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LatestDataWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        if (snapshot.data!.docs.isEmpty) {
          return const Text('No data available.');
        }
        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Humidity: ${data['humidity']}'),
            Text('Peltier Status: ${data['peltier_status']}'),
            Text('System State: ${data['system_state']}'),
            Text('Temperature: ${data['temperature']}'),
            Text('Timestamp: ${data['timestamp']}'),
          ],
        );
      },
    );
  }
}