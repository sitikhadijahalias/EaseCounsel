import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:councelease/Ketua%20Jabatan/profilketuajabatan.dart';
import 'dashboard.dart';

class HomePageKetuaJabatan extends StatefulWidget {
  final DocumentSnapshot userDoc;

  HomePageKetuaJabatan({required this.userDoc});

  @override
  _HomePageKetuaJabatanState createState() => _HomePageKetuaJabatanState();
}

class _HomePageKetuaJabatanState extends State<HomePageKetuaJabatan> {
  String _departmentName = "Jabatan";
  String _departmentEmail = "ketuajabatan@example.com";
  String _profilePicture =
      "assets/profile_picture.png"; // Default profile picture

  @override
  void initState() {
    super.initState();
    _fetchDepartmentData();
    // Remove _listenForNotifications since it's currently empty
  }

  void _fetchDepartmentData() async {
    DocumentSnapshot departmentSnapshot = await FirebaseFirestore.instance
        .collection('department_heads')
        .doc(widget.userDoc.id)
        .get();

    setState(() {
      _departmentName = departmentSnapshot['name'] ?? "Jabatan";
      _departmentEmail =
          departmentSnapshot['email'] ?? "ketuajabatan@example.com";
      _profilePicture =
          departmentSnapshot['profilePicture'] ?? "assets/profile_picture.png";
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
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCC80),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                _departmentName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              accountEmail: Text(
                _departmentEmail,
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
                color: Color(0xFFFFCC80), // Orange color
              ),
            ),
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue, // Blue box color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                "Profil Ketua Jabatan",
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () => _navigateToPage(
                  context, ProfileAdminPage(userDoc: widget.userDoc)),
            ),
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red, // Green box color
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: Colors.white),
              ),
              title: Text(
                "Log Keluar",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _logOut(context),
            ),
          ],
        ),
      ),
      body: Dashboard(),
    );
  }
}
