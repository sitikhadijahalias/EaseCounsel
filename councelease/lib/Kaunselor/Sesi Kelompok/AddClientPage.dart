import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGroupClientPage extends StatefulWidget {
  final String sessionId;
  final String refNumber;

  AddGroupClientPage(this.sessionId, this.refNumber);

  @override
  _AddGroupClientPageState createState() => _AddGroupClientPageState();
}

class _AddGroupClientPageState extends State<AddGroupClientPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  DocumentSnapshot? _selectedClient;
  List<Map<String, dynamic>> _groupClients = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupClients();
  }

  Future<void> _fetchGroupClients() async {
    var clientsCollection = FirebaseFirestore.instance
        .collection('group_sessions')
        .doc(widget.sessionId)
        .collection('clients');
    var querySnapshot = await clientsCollection.get();
    setState(() {
      _groupClients = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void _searchClients(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    var clientsCollection = FirebaseFirestore.instance.collection('clients');
    var querySnapshot = await clientsCollection
        .where('ic', isGreaterThanOrEqualTo: query)
        .where('ic', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    setState(() {
      _searchResults = querySnapshot.docs;
    });
  }

  void _selectClient(DocumentSnapshot client) {
    setState(() {
      _selectedClient = client;
    });
  }

  void _addClientToGroup() async {
    if (_selectedClient != null) {
      var clientsCollection = FirebaseFirestore.instance
          .collection('group_sessions')
          .doc(widget.sessionId)
          .collection('clients');
      var clientData = _selectedClient!.data() as Map<String, dynamic>;
      await clientsCollection.doc(clientData['client_id']).set({
        'client_id': clientData['client_id'],
        'name': clientData['name'],
        'ic': clientData['ic'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klien berjaya ditambah ke sesi kelompok!')),
      );
      _fetchGroupClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Klien - ${widget.refNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ref Number: ${widget.refNumber}'),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari No IC Klien',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchClients(_searchController.text),
                ),
              ),
              onChanged: _searchClients,
            ),
            SizedBox(height: 10),
            Expanded(
              child: _searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var client = _searchResults[index];
                        return ListTile(
                          title: Text(client['name']),
                          subtitle: Text('No IC: ${client['ic']}'),
                          onTap: () => _selectClient(client),
                        );
                      },
                    )
                  : Center(
                      child: Text('Tiada klien dijumpai.'),
                    ),
            ),
            SizedBox(height: 20),
            if (_selectedClient != null) ...[
              Text(
                'Klien Sesi Kelompok',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Name'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No IC'),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedClient!['name']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_selectedClient!['ic']),
                    ),
                  ]),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addClientToGroup,
                child: Text('Daftar Klien'),
              ),
            ],
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _groupClients.length,
                itemBuilder: (context, index) {
                  var client = _groupClients[index];
                  return ListTile(
                    title: Text(client['name']),
                    subtitle: Text('No IC: ${client['ic']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
