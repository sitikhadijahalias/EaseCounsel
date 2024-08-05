import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilKaunselor extends StatefulWidget {
  final DocumentSnapshot? userDoc;

  ProfilKaunselor({this.userDoc});

  @override
  _ProfilKaunselorState createState() => _ProfilKaunselorState();
}

class _ProfilKaunselorState extends State<ProfilKaunselor> {
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

  @override
  void initState() {
    super.initState();
    if (widget.userDoc != null) {
      _nameController.text = widget.userDoc!['name'] ?? '';
      _icController.text = widget.userDoc!['idNumber'] ?? '';
      _phoneController.text = widget.userDoc!['phoneNumber'] ?? '';
      _emailController.text = widget.userDoc!['email'] ?? '';
      _addressController.text = widget.userDoc!['address'] ?? '';
      _positionController.text = widget.userDoc!['position'] ?? '';
      _workplaceController.text = widget.userDoc!['workPlace'] ?? '';
      _stateController.text = widget.userDoc!['state'] ?? '';
      _registrationController.text =
          widget.userDoc!['registrationNumber'] ?? '';
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    String? imageUrl = widget.userDoc?['profileImageUrl'];

    if (_imageFile != null) {
      // Upload image to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${widget.userDoc?.id ?? 'new_user'}.jpg');

      await ref.putFile(_imageFile!);
      imageUrl = await ref.getDownloadURL();
    }

    // Update or set Firestore document with profile information
    if (widget.userDoc != null) {
      await widget.userDoc!.reference.update({
        'profileImageUrl': imageUrl,
        'name': _nameController.text,
        'idNumber': _icController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'position': _positionController.text,
        'workPlace': _workplaceController.text,
        'state': _stateController.text,
        'registrationNumber': _registrationController.text,
      });

      // Show a SnackBar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maklumat berjaya kemaskini'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await FirebaseFirestore.instance.collection('councillors').add({
        'profileImageUrl': imageUrl,
        'name': _nameController.text,
        'idNumber': _icController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'position': _positionController.text,
        'workPlace': _workplaceController.text,
        'state': _stateController.text,
        'registrationNumber': _registrationController.text,
      });

      // Show a SnackBar to indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maklumat berjaya disimpan'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC80),
      appBar: AppBar(
        title: Text('Profil Kaunselor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _uploadImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : widget.userDoc != null &&
                              widget.userDoc!['profileImageUrl'] != null
                          ? NetworkImage(widget.userDoc!['profileImageUrl'])
                              as ImageProvider
                          : AssetImage('assets/profile_picture.png')
                              as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_icController, 'IC'),
            _buildTextField(_phoneController, 'Phone Number'),
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_addressController, 'Address'),
            _buildTextField(_positionController, 'Position'),
            _buildTextField(_workplaceController, 'Workplace'),
            _buildTextField(_stateController, 'State'),
            _buildTextField(_registrationController, 'Registration'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Kemaskini Maklumat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
