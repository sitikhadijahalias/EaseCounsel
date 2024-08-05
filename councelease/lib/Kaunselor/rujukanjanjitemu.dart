import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ClientAppointmentsPage extends StatefulWidget {
  final String counselorName;

  ClientAppointmentsPage({required this.counselorName});

  @override
  _ClientAppointmentsPageState createState() => _ClientAppointmentsPageState();
}

class _ClientAppointmentsPageState extends State<ClientAppointmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rujukan Janji'),
        backgroundColor: Color(0xFFFFCC80),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('counselor', isEqualTo: widget.counselorName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var appointments = snapshot.data!.docs;

          if (appointments.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointmentDoc = appointments[index];
              var appointment = Appointment.fromFirestore(appointmentDoc);

              return Card(
                child: ListTile(
                  title: Text('Client: ${appointment.name}'),
                  subtitle: Text(
                      'Date: ${DateFormat('dd-MM-yyyy HH:mm').format(appointment.appointmentTimestamp)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentDetailPage(
                          appointment: appointment,
                          appointmentId: '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Appointment {
  final String address;
  final DateTime appointmentTimestamp;
  final DateTime birthDate;
  final String birthOrder;
  final String city;
  final String counselor;
  final String email;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String gender;
  final String ic;
  final String name;
  final String phone;
  final String postcode;
  final String race;
  final String relationship;
  final String religion;
  final String siblings;
  final String state;
  final String status;

  Appointment({
    required this.address,
    required this.appointmentTimestamp,
    required this.birthDate,
    required this.birthOrder,
    required this.city,
    required this.counselor,
    required this.email,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.gender,
    required this.ic,
    required this.name,
    required this.phone,
    required this.postcode,
    required this.race,
    required this.relationship,
    required this.religion,
    required this.siblings,
    required this.state,
    required this.status,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Appointment(
      address: data['address'],
      appointmentTimestamp:
          (data['appointmentTimestamp'] as Timestamp).toDate(),
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      birthOrder: data['birthOrder'],
      city: data['city'],
      counselor: data['counselor'],
      email: data['email'],
      emergencyContactName: data['emergencyContactName'],
      emergencyContactPhone: data['emergencyContactPhone'],
      gender: data['gender'],
      ic: data['ic'],
      name: data['name'],
      phone: data['phone'],
      postcode: data['postcode'],
      race: data['race'],
      relationship: data['relationship'],
      religion: data['religion'],
      siblings: data['siblings'],
      state: data['state'],
      status: data['status'],
    );
  }
}

class AppointmentDetailPage extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailPage(
      {required this.appointment, required String appointmentId});

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
