import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:councelease/Kaunselor/Sesi%20Kelompok/GroupReportsPage.dart';

class GroupClientListScreen extends StatefulWidget {
  @override
  _GroupClientListScreenState createState() => _GroupClientListScreenState();
}

class _GroupClientListScreenState extends State<GroupClientListScreen> {
  List<DocumentSnapshot> _allGroupClients = [];

  @override
  void initState() {
    super.initState();
    _fetchAllGroupClients();
  }

  void _fetchAllGroupClients() async {
    var groupClientsCollection =
        FirebaseFirestore.instance.collection('group_sessions');
    var querySnapshot = await groupClientsCollection.get();

    setState(() {
      _allGroupClients = querySnapshot.docs;
    });
  }

  void _deleteGroupClient(String clientId) async {
    await FirebaseFirestore.instance
        .collection('group_sessions')
        .doc(clientId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Klien telah dihapuskan')),
    );
    _fetchAllGroupClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Senarai Klien Kelompok'),
      ),
      body: _allGroupClients.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allGroupClients.length,
              itemBuilder: (context, index) {
                var groupClient = _allGroupClients[index];
                return ListTile(
                  title: Text(groupClient['ref_number']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteGroupClient(groupClient.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupReportsPage(
                          groupClient.id,
                          groupClient['ref_number'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
