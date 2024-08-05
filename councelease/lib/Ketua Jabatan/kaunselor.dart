import 'dart:io';
import 'package:councelease/Kaunselor/profilkaunselor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class KaunselorsPage extends StatefulWidget {
  @override
  _KaunselorsPageState createState() => _KaunselorsPageState();
}

class _KaunselorsPageState extends State<KaunselorsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _icNumberController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _positionController = TextEditingController();
  TextEditingController _workplaceController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _registrationController = TextEditingController();

  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC80), // Change background color here
      appBar: AppBar(
        title: Text('Kaunselor Berdaftar'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddCounselorDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('councillors').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var counselors = snapshot.data!.docs;

            return ListView.builder(
              itemCount: counselors.length,
              itemBuilder: (context, index) {
                var counselor = counselors[index];
                var counselorData = counselor.data() as Map<String, dynamic>;
                String name = counselorData['name'] ?? 'No Name';
                String email = counselorData['email'] ?? 'No Email';
                String profileImageUrl = counselorData['profileImageUrl'] ?? '';

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundImage: profileImageUrl.startsWith('http')
                          ? NetworkImage(profileImageUrl)
                              as ImageProvider // Cast to ImageProvider for NetworkImage
                          : AssetImage('assets/profile_picture.png')
                              as ImageProvider, // Cast to ImageProvider for AssetImage
                    ),
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.print),
                          onPressed: () => _printCounselor(counselor),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteCounselor(context, counselor),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilKaunselor(userDoc: counselor),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddCounselorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Daftar Kaunselor'),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _uploadImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : AssetImage('assets/profile_picture.png')
                                  as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _icNumberController,
                        decoration: InputDecoration(
                          labelText: 'IC Number',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _positionController,
                        decoration: InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _workplaceController,
                        decoration: InputDecoration(
                          labelText: 'Workplace',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _stateController,
                        decoration: InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _registrationController,
                        decoration: InputDecoration(
                          labelText: 'Registration Number',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: _registerCounselor,
                  child: Text('Register'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerCounselor() async {
    String email = _emailController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String name = _nameController.text.trim();
    String idNumber = _icNumberController.text.trim();
    String phoneNumber = _phoneController.text.trim();
    String address = _addressController.text.trim();
    String position = _positionController.text.trim();
    String workPlace = _workplaceController.text.trim();
    String state = _stateController.text.trim();
    String registrationNumber = _registrationController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String? imageUrl;
        if (_imageFile != null) {
          // Upload image to Firebase Storage
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('profile_pictures')
              .child('${userCredential.user!.uid}.jpg');

          await ref.putFile(_imageFile!);
          imageUrl = await ref.getDownloadURL();
        }

        await _firestore
            .collection('councillors')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'username': username,
          'name': name,
          'idNumber': idNumber,
          'phoneNumber': phoneNumber,
          'address': address,
          'position': position,
          'workPlace': workPlace,
          'state': state,
          'registrationNumber': registrationNumber,
          'profileImageUrl':
              imageUrl ?? 'assets/profile_picture.png', // Default image
        });

        Navigator.pop(context);
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _nameController.clear();
        _icNumberController.clear();
        _phoneController.clear();
        _addressController.clear();
        _positionController.clear();
        _workplaceController.clear();
        _stateController.clear();
        _registrationController.clear();
      } catch (e) {
        print(e);
        // Handle error appropriately
      }
    }
  }

  Future<void> _deleteCounselor(
      BuildContext context, DocumentSnapshot counselor) async {
    String uid = counselor.id; // Retrieves counselor document ID

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'), // Dialog title
        content: Text(
            'Are you sure you want to delete this counselor?'), // Confirmation message
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Closes confirmation dialog
              try {
                await _firestore
                    .collection('councillors')
                    .doc(uid)
                    .delete(); // Deletes counselor document from Firestore
                User? user = await _auth.currentUser;
                await user
                    ?.delete(); // Deletes counselor user from Firebase Authentication
              } catch (e) {
                print(e); // Prints error message if deletion fails
                // Handle error appropriately
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _printCounselor(DocumentSnapshot counselor) async {
    final pdf = pw.Document();

    // Define colors for aesthetics
    final accentColor = PdfColor.fromHex('#FF5722');
    final lightColor = PdfColor.fromHex('#FFCCBC');
    final darkColor = PdfColor.fromHex('#E64A19');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo and title
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                color: accentColor,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // App logo

                    // Title
                    pw.Text(
                      'Maklumat Kaunselor',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Spacer
              pw.SizedBox(height: 20),
              // Details section
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                color: lightColor,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Maklumat Kaunselor',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    // Details
                    _buildDetailRow('Name', counselor['name']),
                    _buildDetailRow('Email', counselor['email']),
                    _buildDetailRow('IC Number', counselor['idNumber']),
                    _buildDetailRow(
                        'Phone', counselor['phoneNumber'] ?? 'Not Provided'),
                    _buildDetailRow(
                        'Address', counselor['address'] ?? 'Not Provided'),
                    _buildDetailRow(
                        'Position', counselor['position'] ?? 'Not Provided'),
                    _buildDetailRow(
                        'Workplace', counselor['workPlace'] ?? 'Not Provided'),
                    _buildDetailRow(
                        'State', counselor['state'] ?? 'Not Provided'),
                    _buildDetailRow('Registration Number',
                        counselor['registrationNumber'] ?? 'Not Provided'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

// Helper function to build a row of details
  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 100,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
