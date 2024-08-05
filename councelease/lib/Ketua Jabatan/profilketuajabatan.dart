import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAdminPage extends StatefulWidget {
  final DocumentSnapshot userDoc;

  ProfileAdminPage({required this.userDoc});

  @override
  _ProfileAdminPageState createState() => _ProfileAdminPageState();
}

class _ProfileAdminPageState extends State<ProfileAdminPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _icController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _positionController = TextEditingController();
  TextEditingController _workplaceController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController _registrationController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    String imageUrl = widget.userDoc['profilePicture'];

    if (_imageFile != null) {
      // Upload image to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${widget.userDoc.id}.jpg');

      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    // Update Firestore document with profile information
    await widget.userDoc.reference.update({
      'profilePicture': imageUrl,
      'name': _nameController.text,
      'icNumber': _icController.text,
      'phoneNumber': _phoneController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'position': _positionController.text,
      'workplace': _workplaceController.text,
      'state': _stateController.text,
      'registrationNumber': _registrationController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userDoc['name'] ?? '';
    _icController.text = widget.userDoc['icNumber'] ?? '';
    _phoneController.text = widget.userDoc['phoneNumber'] ?? '';
    _emailController.text = widget.userDoc['email'] ?? '';
    _addressController.text = widget.userDoc['address'] ?? '';
    _positionController.text = widget.userDoc['position'] ?? '';
    _workplaceController.text = widget.userDoc['workplace'] ?? '';
    _stateController.text = widget.userDoc['state'] ?? '';
    _registrationController.text = widget.userDoc['registrationNumber'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profil Ketua Jabatan',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black), // Back arrow color
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _uploadImage,
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) // Use FileImage for local file
                      : widget.userDoc['profilePicture'] != null
                          ? NetworkImage(widget.userDoc['profilePicture'])
                              as ImageProvider // Cast to ImageProvider
                          : AssetImage(
                              'assets/placeholder_image.jpg'), // Placeholder image if no image is available
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(_nameController, 'Nama'),
            SizedBox(height: 12),
            _buildTextField(_icController, 'No. Kad Pengenalan'),
            SizedBox(height: 12),
            _buildTextField(_phoneController, 'No. Telefon'),
            SizedBox(height: 12),
            _buildTextField(_emailController, 'Email'),
            SizedBox(height: 12),
            _buildTextField(_addressController, 'Alamat'),
            SizedBox(height: 12),
            _buildTextField(_positionController, 'Jawatan'),
            SizedBox(height: 12),
            _buildTextField(_workplaceController, 'Tempat Bertugas'),
            SizedBox(height: 12),
            _buildTextField(_stateController, 'Negeri'),
            SizedBox(height: 12),
            _buildTextField(_registrationController, 'No. Pendaftaran'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero, // Remove padding
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 211, 107, 58),
                      Color.fromARGB(255, 209, 130, 84),
                      Color.fromARGB(255, 236, 114, 65),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                constraints: BoxConstraints(minWidth: 150, minHeight: 50),
                child: Text(
                  'Kemaskini Maklumat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String labelText) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.orange),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
