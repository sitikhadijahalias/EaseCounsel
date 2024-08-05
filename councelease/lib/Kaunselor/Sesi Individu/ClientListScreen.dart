import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:councelease/Kaunselor/Sesi%20Individu/ClientIndividuReportsPage.dart';

class ClientListScreen extends StatefulWidget {
  @override
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<DocumentSnapshot> _allClients = [];

  @override
  void initState() {
    super.initState();
    _fetchAllClients();
  }

  void _fetchAllClients() async {
    var clientsCollection = FirebaseFirestore.instance.collection('clients');
    var querySnapshot = await clientsCollection.get();

    setState(() {
      _allClients = querySnapshot.docs;
    });
  }

  void _deleteClient(String clientId) async {
    await FirebaseFirestore.instance
        .collection('clients')
        .doc(clientId)
        .delete();
    _fetchAllClients(); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Senarai Klien'),
      ),
      body: _allClients.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allClients.length,
              itemBuilder: (context, index) {
                var client = _allClients[index];
                return ListTile(
                  title: Text(client['ic']),
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
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Pengesahan'),
                            content: Text(
                                'Adakah anda pasti untuk memadam klien ini?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Batal'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Padam'),
                                onPressed: () {
                                  _deleteClient(client.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
