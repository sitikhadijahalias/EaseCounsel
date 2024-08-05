import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RujukanPenilaianSesi extends StatefulWidget {
  @override
  _RujukanPenilaianSesiState createState() => _RujukanPenilaianSesiState();
}

class _RujukanPenilaianSesiState extends State<RujukanPenilaianSesi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rujukan Penilaian Sesi'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('session_evaluations')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text('IC Client: ${data['ic']}'),
                  subtitle: Text('Timestamp: ${data['timestamp']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailRujukanPenilaianSesi(data: data)),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class DetailRujukanPenilaianSesi extends StatelessWidget {
  final Map<String, dynamic> data;

  DetailRujukanPenilaianSesi({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Penilaian Sesi'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Name Counselor: ${data['counselorName']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Tarikh Sesi: ${_formatDate(data['sessionDate'])}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Jenis Sesi: ${data['sessionType']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Penilaian Sesi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            _buildFeedbackItem(
                "Saya rasa lebih lega sekarang", data['feedbackRatings'][0]),
            _buildFeedbackItem("Saya boleh mendengar isi hati saya",
                data['feedbackRatings'][1]),
            _buildFeedbackItem("Saya yakin saya tidak keseorangan lagi",
                data['feedbackRatings'][2]),
            _buildFeedbackItem(
                "Saya dapat mengawal emosi saya", data['feedbackRatings'][3]),
            _buildFeedbackItem(
                "Saya tahu apa yang saya hadapi", data['feedbackRatings'][4]),
            _buildFeedbackItem(
                "Saya dapati sesi kaunseling ini dapat membantu saya",
                data['feedbackRatings'][5]),
            SizedBox(height: 20),
            Text(
              'Ulasan Klien:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '${data['clientReview']}',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildFeedbackItem(String question, dynamic rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question,
          ),
          SizedBox(height: 4),
          Text(
            'Rating: ${rating ?? "Not provided"}',
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
