import 'package:councelease/Kaunselor/Sesi%20Kelompok/GroupSessionSearchScreen.dart';
import 'package:councelease/Kaunselor/Sesi%20Individu/cariklien.dart';
import 'package:flutter/material.dart';
import 'ServiceClientListScreen.dart'; // Import the new screen

class CounselorServiceOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Perkhidmatan Kaunselor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFFFA000), // Dark orange color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptionButton(
              context,
              "Sesi Individu",
              SearchClientScreen(),
            ),
            SizedBox(height: 20),
            _buildOptionButton(
              context,
              "Sesi Kelompok",
              SearchGroupSessionScreen(),
            ),
            SizedBox(height: 20),
            _buildOptionButton(
              context,
              "Senarai Klien Yang Mendapatkan Perkhidmatan",
              ServiceClientListScreen(),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFFFF3E0), // Light background color
    );
  }

  Widget _buildOptionButton(BuildContext context, String title, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => screen,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFA000), // Orange color
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
