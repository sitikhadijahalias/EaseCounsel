import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:councelease/Kaunselor/Sesi%20Kelompok/GroupReportsPage.dart';
import 'package:councelease/Kaunselor/Sesi%20Kelompok/GroupClientListScreen.dart';

class SearchGroupSessionScreen extends StatefulWidget {
  @override
  _SearchGroupSessionScreenState createState() =>
      _SearchGroupSessionScreenState();
}

class _SearchGroupSessionScreenState extends State<SearchGroupSessionScreen> {
  final TextEditingController _refNumberController = TextEditingController();
  List<DocumentSnapshot> _matchingSessions = [];

  void _searchGroupSession() async {
    String refNumber = _refNumberController.text.trim();

    var sessionsCollection =
        FirebaseFirestore.instance.collection('group_sessions');
    var querySnapshot = await sessionsCollection
        .where('ref_number', isEqualTo: refNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var sessionId = querySnapshot.docs.first.id;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupReportsPage(sessionId, refNumber),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sesi Tidak Ditemui'),
          content:
              Text('Tiada sesi ditemui dengan nombor rujukan yang dimasukkan.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _registerNewGroupSession() async {
    var sessionsCollection =
        FirebaseFirestore.instance.collection('group_sessions');
    var querySnapshot = await sessionsCollection.get();
    var newRefNumber =
        'AA${(querySnapshot.docs.length + 1).toString().padLeft(2, '0')}${DateTime.now().year.toString().substring(2)}';

    await sessionsCollection.doc(newRefNumber).set({
      'ref_number': newRefNumber,
      'created_at': Timestamp.now(),
    });

    // Provide a default value for sessionId if it can be null
    String defaultSessionId = 'default_session_id';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupReportsPage(defaultSessionId, newRefNumber),
      ),
    );
  }

  void _viewGroupClientList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupClientListScreen()),
    );
  }

  void _updateMatchingSessions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _matchingSessions = [];
      });
      return;
    }

    var sessionsCollection =
        FirebaseFirestore.instance.collection('group_sessions');
    var querySnapshot = await sessionsCollection
        .where('ref_number', isGreaterThanOrEqualTo: query)
        .where('ref_number', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _matchingSessions = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cari Sesi Kelompok'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _refNumberController,
              decoration: InputDecoration(
                labelText: 'Masukkan No Rujukan',
              ),
              onChanged: (value) {
                _updateMatchingSessions(value);
              },
            ),
            SizedBox(height: 10),
            if (_matchingSessions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _matchingSessions.length,
                  itemBuilder: (context, index) {
                    var session = _matchingSessions[index];
                    return ListTile(
                      title: Text(session['ref_number']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupReportsPage(
                              session.id,
                              session['ref_number'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchGroupSession,
              child: Text('Cari'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerNewGroupSession,
              child: Text('Daftar Sesi Kelompok Baru'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _viewGroupClientList,
              child: Text('Senarai Klien Kelompok'),
            ),
          ],
        ),
      ),
    );
  }
}
