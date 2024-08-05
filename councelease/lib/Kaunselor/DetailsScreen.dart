import 'package:councelease/Kaunselor/rujukanjanjitemu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class AppointmentDetailPage extends StatelessWidget {
  final Appointment appointment;
  final String appointmentId;

  AppointmentDetailPage({
    required this.appointment,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DetailRow(label: 'Name', value: appointment.name),
            DetailRow(label: 'IC', value: appointment.ic),
            DetailRow(label: 'Counselor', value: appointment.counselor),
            DetailRow(
                label: 'Appointment Date',
                value: DateFormat('dd-MM-yyyy HH:mm')
                    .format(appointment.appointmentTimestamp)),
            DetailRow(label: 'Address', value: appointment.address),
            DetailRow(
                label: 'Birth Date',
                value: DateFormat('dd-MM-yyyy').format(appointment.birthDate)),
            DetailRow(label: 'Birth Order', value: appointment.birthOrder),
            DetailRow(label: 'City', value: appointment.city),
            DetailRow(label: 'Email', value: appointment.email),
            DetailRow(
                label: 'Emergency Contact Name',
                value: appointment.emergencyContactName),
            DetailRow(
                label: 'Emergency Contact Phone',
                value: appointment.emergencyContactPhone),
            DetailRow(label: 'Gender', value: appointment.gender),
            DetailRow(label: 'Phone', value: appointment.phone),
            DetailRow(label: 'Postcode', value: appointment.postcode),
            DetailRow(label: 'Race', value: appointment.race),
            DetailRow(label: 'Relationship', value: appointment.relationship),
            DetailRow(label: 'Religion', value: appointment.religion),
            DetailRow(label: 'Siblings', value: appointment.siblings),
            DetailRow(label: 'State', value: appointment.state),
            DetailRow(label: 'Status', value: appointment.status),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
