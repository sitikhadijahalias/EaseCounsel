import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Kaunselor/homepagekaunselor.dart';

class LogMasukKaunselor extends StatefulWidget {
  @override
  _LogMasukKaunselorState createState() => _LogMasukKaunselorState();
}

class _LogMasukKaunselorState extends State<LogMasukKaunselor> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Sila isi semua medan');
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('councillors')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showSnackBar('ID Pengguna tidak dijumpai');
        return;
      }

      final userDoc = querySnapshot.docs.first;
      final userEmail = userDoc['email'];

      if (userEmail == null) {
        _showSnackBar('Emel pengguna tidak dijumpai');
        return;
      }

      await _auth.signInWithEmailAndPassword(
          email: userEmail, password: password);
      _showSnackBar('Log Masuk berjaya');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePageKaunselor(
                  userDoc: userDoc,
                )),
      );
    } catch (e) {
      _showSnackBar('Ralat: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC80),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 200),
              Image.asset(
                'assets/Counsel.png',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Log Masuk Kaunselor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              _buildTextField(
                controller: _usernameController,
                labelText: 'ID Pengguna',
                isPassword: false,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Kata Laluan',
                isPassword: true,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _login,
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return Colors.transparent;
                    },
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(vertical: 16),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide.none,
                    ),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 211, 107, 58),
                        Color.fromARGB(255, 209, 130, 84),
                        Color.fromARGB(255, 236, 114, 65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    constraints:
                        BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
                    child: Text(
                      'Log Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool isPassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
