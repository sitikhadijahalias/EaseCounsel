import 'dart:io';
import 'package:councelease/Kaunselor/Sesi%20Individu/perkhidmatankaunselor.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Reports App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GroupReportsHomePage(),
    );
  }
}

class GroupReportsHomePage extends StatefulWidget {
  @override
  _GroupReportsHomePageState createState() => _GroupReportsHomePageState();
}

class _GroupReportsHomePageState extends State<GroupReportsHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Reports Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GroupReportsPage('sessionID123', 'REF123'),
              ),
            );
          },
          child: Text('Go to Group Reports Page'),
        ),
      ),
    );
  }
}

class GroupReportsPage extends StatefulWidget {
  final String sessionId;
  final String refNumber;

  GroupReportsPage(this.sessionId, this.refNumber);

  @override
  _GroupReportsPageState createState() => _GroupReportsPageState();
}

class _GroupReportsPageState extends State<GroupReportsPage> {
  List<DocumentSnapshot> _reports = [];
  List<Map<String, dynamic>> _clients = [];
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _selectedClient;

  @override
  void initState() {
    super.initState();
    _fetchGroupReports();
    _fetchClients();
  }

  Future<void> _fetchGroupReports() async {
    var reportsCollection = FirebaseFirestore.instance
        .collection('group_sessions')
        .doc(widget.sessionId)
        .collection('reports');
    var querySnapshot = await reportsCollection.get();
    setState(() {
      _reports = querySnapshot.docs;
    });
  }

  Future<void> _fetchClients() async {
    var clientsCollection = FirebaseFirestore.instance
        .collection('group_sessions')
        .doc(widget.sessionId)
        .collection('clients');
    var querySnapshot = await clientsCollection.get();
    setState(() {
      _clients = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void _addReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGroupReportPage(widget.sessionId),
      ),
    ).then((_) {
      _fetchGroupReports();
    });
  }

  void _viewReportDetails(BuildContext context, DocumentSnapshot report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupReportDetailsPage(report),
      ),
    );
  }

  Future<void> _searchClientIC() async {
    var clientsCollection = FirebaseFirestore.instance.collection('clients');
    var querySnapshot = await clientsCollection
        .where('ic', isGreaterThanOrEqualTo: _searchController.text)
        .where('ic', isLessThan: _searchController.text + 'z')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _selectedClient = querySnapshot.docs.first.data();
      });
    } else {
      setState(() {
        _selectedClient = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Klien tidak dijumpai')),
      );
    }
  }

  void _addClient() {
    if (_selectedClient != null) {
      setState(() {
        _clients.add(_selectedClient!);
      });
      FirebaseFirestore.instance
          .collection('group_sessions')
          .doc(widget.sessionId)
          .collection('clients')
          .add(_selectedClient!);
      _selectedClient = null;
      _searchController.clear();
    }
  }

  void _removeClient(int index) async {
    var clientsCollection = FirebaseFirestore.instance
        .collection('group_sessions')
        .doc(widget.sessionId)
        .collection('clients');
    var clientDocs = await clientsCollection
        .where('ic', isEqualTo: _clients[index]['ic'])
        .get();
    for (var doc in clientDocs.docs) {
      await doc.reference.delete();
    }

    setState(() {
      _clients.removeAt(index);
    });
  }

  Future<void> _registerClients() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerkhidmatanKaunselor(clients: _clients),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Reports - ${widget.refNumber}'),
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
              onChanged: (_) {
                _searchClientIC();
              },
              decoration: InputDecoration(
                labelText: 'Search Client IC',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchClientIC,
                ),
              ),
            ),
            SizedBox(height: 10),
            if (_selectedClient != null)
              ListTile(
                title: Text('IC: ${_selectedClient!['ic']}'),
                subtitle: Text('Name: ${_selectedClient!['name']}'),
                trailing: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addClient,
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _registerClients,
              child: Text('Daftar Klien'),
            ),
            SizedBox(height: 20),
            Text(
              'Senarai Klien',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  var client = _clients[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text('IC: ${client['ic']}'),
                      subtitle: Text('Name: ${client['name']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _removeClient(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Laporan Sesi Kelompok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  var report =
                      _reports[index].data() as Map<String, dynamic>? ?? {};
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text('Laporan ${index + 1}'),
                      subtitle:
                          Text('Status: ${report['status'] ?? 'No data'}'),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: Icon(Icons.print),
                            onPressed: () {
                              _printReport(report);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editReport(_reports[index]);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteReport(_reports[index]);
                            },
                          ),
                        ],
                      ),
                      onTap: () => _viewReportDetails(context, _reports[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addReport(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _editReport(DocumentSnapshot report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupReportPage(widget.sessionId, report),
      ),
    ).then((_) {
      _fetchGroupReports();
    });
  }

  void _deleteReport(DocumentSnapshot report) async {
    await report.reference.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Laporan telah dihapus')),
    );
    _fetchGroupReports();
  }

  void _printReport(Map<String, dynamic> report) async {
    try {
      // Assuming _clients is accessible in this scope
      File pdfFile =
          await GroupReportPdfGenerator.generateReportPdf(report, _clients);

      await OpenFile.open(pdfFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan sedang dicetak')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ralat mencetak laporan')),
      );
    }
  }
}

class PerkhidmatanKaunselorPage extends StatelessWidget {
  final List<Map<String, dynamic>> clients;

  PerkhidmatanKaunselorPage({required this.clients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perkhidmatan Kaunselor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: clients.length,
          itemBuilder: (context, index) {
            var client = clients[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('IC: ${client['ic']}'),
                subtitle: Text('Name: ${client['name']}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddGroupReportPage extends StatefulWidget {
  final String sessionId;

  AddGroupReportPage(this.sessionId);

  @override
  _AddGroupReportPageState createState() => _AddGroupReportPageState();
}

class _AddGroupReportPageState extends State<AddGroupReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _latarbelakangController = TextEditingController();
  final _intervensiController = TextEditingController();
  final _catatanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _latarbelakangController,
                decoration: InputDecoration(labelText: 'Latarbelakang Masalah'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Latarbelakang Masalah';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _intervensiController,
                decoration:
                    InputDecoration(labelText: 'Intervensi dan Tahap Kemajuan'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Intervensi dan Tahap Kemajuan';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(labelText: 'Catatan/Ulasan'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Catatan/Ulasan';
                  }
                  return null;
                },
              ),
              ListTile(
                title:
                    Text('Tarikh: ${DateFormat.yMd().format(_selectedDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status Klien'),
                value: _status,
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue;
                  });
                },
                items: <String>['Dalam Proses', 'Tamat', 'Tamat & Rujuk']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Status Klien';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveReport(widget.sessionId);
                },
                child: Text('Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveReport(String sessionId) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch the existing ref_number from group_sessions collection
        DocumentSnapshot sessionSnapshot = await FirebaseFirestore.instance
            .collection('group_sessions')
            .doc(sessionId)
            .get();

        if (sessionSnapshot.exists) {
          String existingRefNumber = sessionSnapshot['ref_number'];

          // Use the existing ref_number
          String refNumber = existingRefNumber;

          // Save the report with the retrieved ref_number
          await FirebaseFirestore.instance
              .collection('group_sessions')
              .doc(sessionId)
              .collection('reports')
              .doc(refNumber)
              .set({
            'ref_number': refNumber,
            'latarbelakang': _latarbelakangController.text,
            'intervensi': _intervensiController.text,
            'catatan': _catatanController.text,
            'tarikh': _selectedDate,
            'status': _status,
          });

          Navigator.pop(context);
        } else {
          // Handle the case where the session document does not exist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session document does not exist.'),
            ),
          );
        }
      } catch (e) {
        // Handle any other errors that might occur
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred: $e'),
          ),
        );
      }
    }
  }
}

@override
Widget build(BuildContext context) {
  var _formKey;
  var _reportController;
  var _saveReport;
  return Scaffold(
    appBar: AppBar(
      title: Text('Add Group Report'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _reportController,
              decoration: InputDecoration(labelText: 'Report'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a report';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReport,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    ),
  );
}

class EditGroupReportPage extends StatefulWidget {
  final String sessionId;
  final DocumentSnapshot report;

  EditGroupReportPage(this.sessionId, this.report);

  @override
  _EditGroupReportPageState createState() => _EditGroupReportPageState();
}

class _EditGroupReportPageState extends State<EditGroupReportPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _latarbelakangController;
  late TextEditingController _intervensiController;
  late TextEditingController _catatanController;
  DateTime _selectedDate = DateTime.now();
  String? _status;

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> reportData =
        widget.report.data() as Map<String, dynamic>;
    _latarbelakangController =
        TextEditingController(text: reportData['latarbelakang']);
    _intervensiController =
        TextEditingController(text: reportData['intervensi']);
    _catatanController = TextEditingController(text: reportData['catatan']);
    _selectedDate = reportData['tarikh'].toDate();
    _status = reportData['status'];
  }

  @override
  void dispose() {
    _latarbelakangController.dispose();
    _intervensiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _updateReport() async {
    if (_formKey.currentState!.validate()) {
      await widget.report.reference.update({
        'latarbelakang': _latarbelakangController.text,
        'intervensi': _intervensiController.text,
        'catatan': _catatanController.text,
        'tarikh': _selectedDate,
        'status': _status,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Group Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _latarbelakangController,
                decoration: InputDecoration(labelText: 'Latarbelakang Masalah'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Latarbelakang Masalah';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _intervensiController,
                decoration:
                    InputDecoration(labelText: 'Intervensi dan Tahap Kemajuan'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Intervensi dan Tahap Kemajuan';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _catatanController,
                decoration: InputDecoration(labelText: 'Catatan/Ulasan'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Catatan/Ulasan';
                  }
                  return null;
                },
              ),
              ListTile(
                title:
                    Text('Tarikh: ${DateFormat.yMd().format(_selectedDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status Klien'),
                value: _status,
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue;
                  });
                },
                items: <String>['Dalam Proses', 'Tamat', 'Tamat & Rujuk']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Status Klien';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateReport,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupReportDetailsPage extends StatelessWidget {
  final DocumentSnapshot report;

  GroupReportDetailsPage(this.report);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> reportData = report.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Group Report Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ref Number: ${reportData['ref_number']}'),
            SizedBox(height: 10),
            Text('Catatan: ${reportData['catatan']}'),
            SizedBox(height: 10),
            Text('Intervensi: ${reportData['intervensi']}'),
            SizedBox(height: 10),
            Text('Latarbelakang: ${reportData['latarbelakang']}'),
            SizedBox(height: 10),
            Text('Status: ${reportData['status']}'),
            SizedBox(height: 10),
            Text(
                'Tarikh: ${DateFormat.yMMMd().format(reportData['tarikh'].toDate())}'),
          ],
        ),
      ),
    );
  }
}

class GroupReportPdfGenerator {
  static Future<File> generateReportPdf(Map<String, dynamic> reportData,
      List<Map<String, dynamic>> clients) async {
    final pdf = pw.Document();

    // Adding title
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'LAPORAN SESI KELOMPOK',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            // Adding client table
            pw.Text(
              'Nama Klien dan IC',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Nama', 'IC'],
                ...clients.map((client) => [client['name'], client['ic']]),
              ],
            ),
            pw.SizedBox(height: 20),

            // Adding other report details
            pw.Text(
              'Ref Number: ${reportData['refNumber'] ?? 'Tiada data'}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Catatan: ${reportData['catatan'] ?? 'Tiada data'}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Intervensi: ${reportData['intervensi'] ?? 'Tiada data'}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Latarbelakang: ${reportData['latarbelakang'] ?? 'Tiada data'}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Status: ${reportData['status'] ?? 'Tiada data'}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Tarikh: ${reportData['tarikh'] ?? 'Tiada data'}',
              style: pw.TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/group_session_report.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
