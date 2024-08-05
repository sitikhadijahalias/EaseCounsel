import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class SessionsPage extends StatefulWidget {
  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _firstDay = DateTime.utc(2024, 1, 1);
  DateTime _lastDay = DateTime.utc(2025, 12, 31);
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    if (_focusedDay.isAfter(_lastDay)) {
      _focusedDay = _lastDay;
    } else if (_focusedDay.isBefore(_firstDay)) {
      _focusedDay = _firstDay;
    }
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      var appointments = await _firestore.collection('appointments').get();
      Map<DateTime, List<dynamic>> events = {};
      for (var appointment in appointments.docs) {
        DateTime appointmentTimestamp;
        if (appointment['appointmentTimestamp'] is Timestamp) {
          appointmentTimestamp =
              (appointment['appointmentTimestamp'] as Timestamp).toDate();
        } else {
          throw 'Invalid appointmentTimestamp type';
        }

        // Group appointments by date
        DateTime dateOnly = DateTime(appointmentTimestamp.year,
            appointmentTimestamp.month, appointmentTimestamp.day);
        events[dateOnly] ??= [];
        events[dateOnly]!.add(appointment.data());
      }

      setState(() {
        _events = events;
      });
    } catch (e) {
      print('Error fetching events: $e');
      // Handle error gracefully, e.g., show error message to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC80),
        title: const Text(
          'Sesi Kaunseling',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: _firstDay,
              lastDay: _lastDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black),
                weekendStyle: TextStyle(color: Colors.black),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Checking if the day has any events
                  if (_events.containsKey(day)) {
                    return Stack(
                      children: [
                        Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${_events[day]!.length}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: Text(
                        '${day.day}',
                      ),
                    );
                  }
                },
              ),
              eventLoader: (day) {
                return _events[day] ?? [];
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('appointments').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var appointments = snapshot.data!.docs.where((doc) {
                    DateTime appointmentTimestamp;
                    try {
                      var data = doc.data() as Map<String, dynamic>;
                      var timestamp = data['appointmentTimestamp'];
                      if (timestamp is Timestamp) {
                        appointmentTimestamp = timestamp.toDate();
                        return isSameDay(_selectedDay, appointmentTimestamp);
                      } else {
                        throw 'Invalid appointmentTimestamp type';
                      }
                    } catch (e) {
                      print('Error parsing appointmentTimestamp: $e');
                      return false;
                    }
                  }).toList();

                  if (appointments.isEmpty) {
                    return Center(
                        child: Text('No appointments for the selected day.'));
                  }

                  return ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      var appointmentData =
                          appointments[index].data() as Map<String, dynamic>;
                      DateTime appointmentTimestamp =
                          (appointmentData['appointmentTimestamp'] as Timestamp)
                              .toDate();

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(appointmentData['name'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${appointmentTimestamp.toString()}'),
                              Text(
                                  'Counselor: ${appointmentData['counselor'] ?? ''}'),
                            ],
                          ),
                          onTap: () {
                            // Navigate to Session Details Page or implement action
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkers(List<dynamic> events) {
    return Positioned(
      right: 1,
      bottom: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        width: 8.0,
        height: 8.0,
      ),
    );
  }
}
