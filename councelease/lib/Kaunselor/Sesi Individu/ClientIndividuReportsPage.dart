import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:councelease/Kaunselor/Sesi%20Individu/report_pdf_generator.dart';

class ClientIndividuReportsPage extends StatefulWidget {
  final String clientId;
  final String clientName;

  ClientIndividuReportsPage(this.clientId, this.clientName);

  @override
  _ClientIndividuReportsPageState createState() =>
      _ClientIndividuReportsPageState();
}

class _ClientIndividuReportsPageState extends State<ClientIndividuReportsPage> {
  late String clientIc;
  late String clientName = ''; // Define clientName variable
  List<DocumentSnapshot> _reports = [];
  bool _isLoadingClientData = true;

  @override
  void initState() {
    super.initState();
    _fetchClientData();
    _fetchClientReports();
  }

  Future<void> _fetchClientData() async {
    var clientDoc = await FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.clientId)
        .get();
    var clientData = clientDoc.data();
    setState(() {
      clientIc = clientData!['ic'];
      clientName = clientData['name']; // Assign clientName here
      _isLoadingClientData = false;
    });
  }

  Future<void> _fetchClientReports() async {
    var reportsCollection = FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.clientId)
        .collection('reports');
    var querySnapshot = await reportsCollection.get();
    setState(() {
      _reports = querySnapshot.docs;
    });
  }

  void _addReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReportPage(widget.clientId),
      ),
    ).then((_) {
      _fetchClientReports();
    });
  }

  void _viewReportDetails(DocumentSnapshot report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsPage(report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Reports - $clientName'), // Use clientName here
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingClientData
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nama: $clientName'),
                  Text('No Kad Pengenalan: $clientIc'),
                  SizedBox(height: 20),
                  Text(
                    'Laporan Sesi Individu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        var report = _reports[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text('Laporan ${index + 1}'),
                            subtitle: Text('Status: ${report['status']}'),
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
                                    _editReport(report);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteReport(report);
                                  },
                                ),
                              ],
                            ),
                            onTap: () => _viewReportDetails(report),
                          ),
                        );
                      },
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: _addReport,
                    child: Icon(Icons.add),
                  ),
                ],
              ),
      ),
    );
  }

  void _editReport(DocumentSnapshot report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReportPage(widget.clientId, report),
      ),
    ).then((_) {
      _fetchClientReports();
    });
  }

  void _deleteReport(DocumentSnapshot report) async {
    await report.reference.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Laporan telah dihapus')),
    );
    _fetchClientReports();
  }

  void _printReport(DocumentSnapshot report) async {
    try {
      Map<String, dynamic> reportData = report.data() as Map<String, dynamic>;
      File pdfFile = await ReportPdfGenerator.generateReportPdf(reportData);

      // Open the generated PDF file
      await OpenFile.open(pdfFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan telah dicetak dan dibuka')),
      );
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencetak laporan: $e')),
      );
      print('Printing error: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

class AddReportPage extends StatefulWidget {
  final String clientId;
  AddReportPage(this.clientId);

  @override
  _AddReportPageState createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _latarbelakangController =
      TextEditingController();
  final TextEditingController _intervensiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _status;
  int _reportCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchReportCount();
  }

  Future<void> _fetchReportCount() async {
    var reportsCollection = FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.clientId)
        .collection('reports');
    var querySnapshot = await reportsCollection.get();
    setState(() {
      _reportCount = querySnapshot.docs.length;
    });
  }

  void _saveReport() async {
    if (_formKey.currentState!.validate()) {
      var reportsCollection = FirebaseFirestore.instance
          .collection('clients')
          .doc(widget.clientId)
          .collection('reports');
      var year = DateTime.now().year.toString().substring(2);
      var reportId = 'LI${(_reportCount + 1).toString().padLeft(2, '0')}$year';
      await reportsCollection.doc(reportId).set({
        'no_rujukan': reportId,
        'latarbelakang': _latarbelakangController.text,
        'intervensi': _intervensiController.text,
        'catatan': _catatanController.text,
        'tarikh': _selectedDate,
        'status': _status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maklumat berjaya disimpan!')),
      );
      Navigator.pop(context);
    }
  }

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
                value: _status,
                items: ['Selesai', 'Dalam Proses', 'Belum Selesai']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
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
}

class ReportDetailsPage extends StatelessWidget {
  final DocumentSnapshot report;

  ReportDetailsPage(this.report);

  @override
  Widget build(BuildContext context) {
    var reportData = report.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No Rujukan: ${reportData['no_rujukan']}'),
            Text('Latarbelakang Masalah: ${reportData['latarbelakang']}'),
            Text('Intervensi dan Tahap Kemajuan: ${reportData['intervensi']}'),
            Text('Catatan/Ulasan: ${reportData['catatan']}'),
            Text(
                'Tarikh: ${DateFormat.yMd().format(reportData['tarikh'].toDate())}'),
            Text('Status: ${reportData['status']}'),
          ],
        ),
      ),
    );
  }
}

class EditReportPage extends StatefulWidget {
  final String clientId;
  final DocumentSnapshot report;

  EditReportPage(this.clientId, this.report);

  @override
  _EditReportPageState createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _latarbelakangController;
  late TextEditingController _intervensiController;
  late TextEditingController _catatanController;
  late DateTime _selectedDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    var reportData = widget.report.data() as Map<String, dynamic>;
    _latarbelakangController =
        TextEditingController(text: reportData['latarbelakang']);
    _intervensiController =
        TextEditingController(text: reportData['intervensi']);
    _catatanController = TextEditingController(text: reportData['catatan']);
    _selectedDate = reportData['tarikh'].toDate();
    _status = reportData['status'];
  }

  void _saveReport() async {
    if (_formKey.currentState!.validate()) {
      await widget.report.reference.update({
        'latarbelakang': _latarbelakangController.text,
        'intervensi': _intervensiController.text,
        'catatan': _catatanController.text,
        'tarikh': _selectedDate,
        'status': _status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maklumat berjaya dikemaskini!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kemaskini Laporan'),
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
                value: _status,
                items: ['Selesai', 'Dalam Proses', 'Belum Selesai']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
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
}
