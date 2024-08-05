import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:councelease/Main%20Page/main.dart';

class PenilaianSesi extends StatefulWidget {
  @override
  _PenilaianSesiState createState() => _PenilaianSesiState();
}

class _PenilaianSesiState extends State<PenilaianSesi> {
  TextEditingController _icController = TextEditingController();
  String? _counselorName;
  DateTime? _sessionDate;
  String? _sessionType;
  List<int?> _feedbackRatings = List.filled(6, null);
  String? _clientReview;
  List<String> _counselorNames = [];

  @override
  void initState() {
    super.initState();
    _fetchCounselorNames();
  }

  Future<void> _fetchCounselorNames() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot snapshot = await firestore.collection('councillors').get();
      List<String> names =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      setState(() {
        _counselorNames = names;
      });
    } catch (e) {
      print("Failed to fetch counselor names: $e");
    }
  }

  Future<void> _submitData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DateTime now = DateTime.now();
      Timestamp currentTime = Timestamp.fromDate(now);

      await firestore.collection('session_evaluations').add({
        'ic': _icController.text,
        'counselorName': _counselorName,
        'sessionDate': _sessionDate,
        'sessionType': _sessionType,
        'feedbackRatings': _feedbackRatings,
        'clientReview': _clientReview,
        'timestamp': _formatTimestamp(currentTime), // Store formatted timestamp
      });
      print("Session evaluation data added to Firestore");

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "BERJAYA!",
              style: TextStyle(color: Colors.orange),
            ),
            content: Text(
              "Penilaian sesi anda telah berjaya dihantar",
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.orange),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CouncelEase()),
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Failed to add session evaluation data: $e");
      // Handle error
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    String formattedDateTime =
        '${dateTime.year}-${_addLeadingZero(dateTime.month)}-${_addLeadingZero(dateTime.day)} '
        '${_addLeadingZero(dateTime.hour)}:${_addLeadingZero(dateTime.minute)}';
    return formattedDateTime;
  }

  String _addLeadingZero(int value) {
    return value < 10 ? '0$value' : '$value';
  }

  InputDecoration _buildOrangeBorderDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.orange),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.orange),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Borang Penilaian Sesi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFFFCC80),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Maklumat Sesi Klien",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _icController,
              decoration: _buildOrangeBorderDecoration("No Kad Pengenalan"),
              onChanged: (value) {
                // Add onChanged functionality
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _counselorName,
              onChanged: (newValue) {
                setState(() {
                  _counselorName = newValue;
                });
              },
              items: _counselorNames.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: _buildOrangeBorderDecoration("Nama Kaunselor"),
            ),
            SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != _sessionDate) {
                  setState(() {
                    _sessionDate = pickedDate;
                  });
                }
              },
              decoration: _buildOrangeBorderDecoration("Tarikh Sesi"),
              controller: TextEditingController(
                text: _sessionDate != null
                    ? "${_sessionDate!.day}/${_sessionDate!.month}/${_sessionDate!.year}"
                    : "",
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _sessionType,
              onChanged: (newValue) {
                setState(() {
                  _sessionType = newValue;
                });
              },
              items: ["Sesi Individu", "Sesi Kelompok"]
                  .map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: _buildOrangeBorderDecoration("Jenis Sesi"),
            ),
            SizedBox(height: 20),
            Text(
              "Penilaian Sesi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "(1) Sangat Tidak Setuju     (2) Tidak Setuju \n (3) Setuju    (4) Sangat Setuju",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            _buildFeedbackItem("Saya rasa lebih lega sekarang", 0),
            _buildFeedbackItem("Saya boleh mendengar isi hati saya", 1),
            _buildFeedbackItem("Saya yakin saya tidak keseorangan lagi", 2),
            _buildFeedbackItem("Saya dapat mengawal emosi saya", 3),
            _buildFeedbackItem("Saya tahu apa yang saya hadapi", 4),
            _buildFeedbackItem(
                "Saya dapati sesi kaunseling ini dapat membantu saya", 5),
            SizedBox(height: 20),
            TextFormField(
              maxLines: 3,
              decoration: _buildOrangeBorderDecoration("Ulasan Klien"),
              onChanged: (value) {
                setState(() {
                  _clientReview = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFCC80),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Hantar",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CuteFont',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackItem(String question, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange), // Orange border
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // evenly spaced buttons
            children: [
              _buildFeedbackButton(1, index),
              _buildFeedbackButton(2, index),
              _buildFeedbackButton(3, index),
              _buildFeedbackButton(4, index),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(int value, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _feedbackRatings[index] = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // smaller button size
        decoration: BoxDecoration(
          color: _feedbackRatings[index] == value
              ? Color(0xFFFFCC80)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _feedbackRatings[index] == value
                ? Color(0xFFFFCC80)
                : Colors.grey,
            width: 2,
          ),
        ),
        child: Text(
          "$value",
          style: TextStyle(
            color:
                _feedbackRatings[index] == value ? Colors.black : Colors.grey,
            fontWeight: _feedbackRatings[index] == value
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
