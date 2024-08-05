import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:councelease/Kaunselor/Report/AnalysisReportPage.dart';
import 'package:councelease/Kaunselor/profilkaunselor.dart';
import 'package:councelease/Kaunselor/rujukanjanjitemu.dart';
import 'package:councelease/Kaunselor/rujukanpenilaiansesi.dart';
import 'package:councelease/Kaunselor/sesikaunseling.dart';
import 'package:councelease/Main%20Page/main.dart';

class HomePageKaunselor extends StatefulWidget {
  final DocumentSnapshot userDoc;

  HomePageKaunselor({required this.userDoc});

  @override
  _HomePageKaunselorState createState() => _HomePageKaunselorState();
}

class _HomePageKaunselorState extends State<HomePageKaunselor> {
  String _counselorName = "Nama Kaunselor";
  String _counselorEmail = "kaunselor@example.com";
  String _profilePicture =
      "assets/profile_picture.png"; // Default profile picture

  @override
  void initState() {
    super.initState();
    _fetchCounselorData();
  }

  void _fetchCounselorData() async {
    var data = widget.userDoc.data() as Map<String, dynamic>;
    setState(() {
      _counselorName = data['name'] ?? _counselorName;
      _counselorEmail = data['email'] ?? _counselorEmail;
      _profilePicture = data['profileImageUrl'] ?? "assets/profile_picture.png";
    });
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Future<void> _logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CouncelEase()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("EaseCounsel"),
        backgroundColor: Color.fromARGB(255, 255, 204, 128),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  _counselorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                accountEmail: Text(
                  _counselorEmail,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: _profilePicture.startsWith('http')
                      ? NetworkImage(_profilePicture)
                      : AssetImage(_profilePicture) as ImageProvider,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFFCC80),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text("Profil Kaunselor"),
                onTap: () => _navigateToPage(
                  context,
                  ProfilKaunselor(userDoc: widget.userDoc),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout, color: Colors.white),
                ),
                title: Text("Log Keluar"),
                onTap: () => _logOut(context),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              "Perkhidmatan Kaunselor",
              "Layanan untuk membantu klien dalam sesi kaunseling.",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CounselorServiceOptionsScreen(),
                ),
              ),
              Color(0xFFB39DDB),
              Icons.person,
            ),
            SizedBox(height: 10),
            _buildCard(
              "Rujukan & Janji Temu",
              "Menguruskan rujukan dan temujanji dengan klien.",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientAppointmentsPage(
                    counselorName: _counselorName,
                  ),
                ),
              ),
              Color(0xFFFFB74D),
              Icons.calendar_today,
            ),
            SizedBox(height: 10),
            _buildCard(
              "Penilaian Sesi",
              "Melaksanakan penilaian terhadap sesi kaunseling.",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RujukanPenilaianSesi(),
                ),
              ),
              Color(0xFF81C784),
              Icons.rate_review,
            ),
            SizedBox(height: 10),
            _buildCard(
              "Laporan Analisis",
              "Membuat laporan analisis kaunseling untuk klien.",
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnalysisReportPage(),
                ),
              ),
              Color(0xFFFFD54F),
              Icons.article,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String description, VoidCallback onPressed,
      Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: color,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 30,
                color: Colors.black,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
