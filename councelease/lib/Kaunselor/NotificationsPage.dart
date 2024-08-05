import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

class NotificationsPage extends StatelessWidget {
  final String counselorName; // Receive counselorName from HomePageKaunselor

  NotificationsPage({required this.counselorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifikasi'),
        backgroundColor: Color.fromARGB(255, 255, 204, 128),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('counselor', isEqualTo: counselorName)
            .where('read', isEqualTo: false)
            .orderBy('appointmentTimestamp', descending: true)
            .limit(1) // Limit to only show the latest appointment
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> appointmentDocs = snapshot.data!.docs;

          if (appointmentDocs.isEmpty) {
            return Center(
              child: Text('Tiada notifikasi baru.'),
            );
          }

          var appointment = appointmentDocs[0].data() as Map<String, dynamic>;
          var clientName = appointment['name'] ?? 'Unknown';
          var appointmentDate =
              appointment['appointmentTimestamp'] ?? Timestamp.now();

          // Format timestamp into readable date format
          var formattedDate =
              DateFormat.yMMMMd().add_jm().format(appointmentDate.toDate());

          return ListTile(
            title: Text(clientName),
            subtitle: Text('Appointment Date: $formattedDate'),
            onTap: () {
              // Navigate to appointment details if needed
            },
          );
        },
      ),
    );
  }
}
