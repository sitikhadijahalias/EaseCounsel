import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:councelease/Kaunselor/Sesi%20Individu/perkhidmatankaunselor.dart';
import 'package:councelease/Kaunselor/Sesi%20Individu/ClientIndividuReportsPage.dart';
import 'package:councelease/Kaunselor/Sesi%20Individu/ClientListScreen.dart';

class SearchClientScreen extends StatefulWidget {
  @override
  _SearchClientScreenState createState() => _SearchClientScreenState();
}

class _SearchClientScreenState extends State<SearchClientScreen> {
  final TextEditingController _icController = TextEditingController();
  List<DocumentSnapshot> _matchingClients = [];

  void _searchClient() async {
    String icNumber = _icController.text.trim();

    var clientsCollection = FirebaseFirestore.instance.collection('clients');
    var querySnapshot =
        await clientsCollection.where('ic', isEqualTo: icNumber).get();

    if (querySnapshot.docs.isNotEmpty) {
      var clientId = querySnapshot.docs.first.id;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClientIndividuReportsPage(clientId, icNumber),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Klien Tidak Ditemui'),
          content:
              Text('Tiada klien ditemui dengan nombor IC yang dimasukkan.'),
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

  void _registerNewClient() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PerkhidmatanKaunselor(
                clients: [],
              )),
    );
  }

  void _viewClientList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ClientListScreen()),
    );
  }

  void _updateMatchingClients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _matchingClients = [];
      });
      return;
    }

    var clientsCollection = FirebaseFirestore.instance.collection('clients');
    var querySnapshot = await clientsCollection
        .where('ic', isGreaterThanOrEqualTo: query)
        .where('ic', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _matchingClients = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cari Klien',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFA000),
          ),
        ),
        //backgroundColor: Color(0xFFFF6F00), // Dark orange color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _icController,
              decoration: InputDecoration(
                labelText: 'Masukkan No Kad Pengenalan',
                labelStyle: TextStyle(color: Color(0xFFFF6F00)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF6F00)),
                ),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _updateMatchingClients(value);
              },
            ),
            SizedBox(height: 10),
            if (_matchingClients.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _matchingClients.length,
                  itemBuilder: (context, index) {
                    var client = _matchingClients[index];
                    return Card(
                      color: Color(0xFFFFF3E0),
                      child: ListTile(
                        title: Text(
                          client['ic'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientIndividuReportsPage(
                                client.id,
                                client['ic'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchClient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFA000), // Orange color
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Cari',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerNewClient,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFA000), // Orange color
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Daftar Klien Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _viewClientList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFA000), // Orange color
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Center(
                child: Text(
                  'Senarai Klien',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFFFF3E0), // Light background color
    );
  }
}
