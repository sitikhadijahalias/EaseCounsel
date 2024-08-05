import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerkhidmatanKaunselor extends StatefulWidget {
  final String? ic;

  PerkhidmatanKaunselor({this.ic, required List<Map<String, dynamic>> clients});

  @override
  _PerkhidmatanKaunselorState createState() => _PerkhidmatanKaunselorState();
}

class _PerkhidmatanKaunselorState extends State<PerkhidmatanKaunselor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _icController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();

  String? _gender;
  String? _religion;
  String? _race;
  String? _status;
  String? _state;

  final List<String> _states = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Wilayah Persekutuan'
  ];

  final List<String> _races = ['Malay', 'Chinese', 'Indian', 'Others'];

  final List<String> _statuses = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void initState() {
    super.initState();
    if (widget.ic != null) {
      _fetchClientData(widget.ic!);
    }
  }

  Future<void> _fetchClientData(String ic) async {
    var clientsCollection = FirebaseFirestore.instance.collection('clients');
    var querySnapshot =
        await clientsCollection.where('ic', isEqualTo: ic).get();

    if (querySnapshot.docs.isNotEmpty) {
      var clientData = querySnapshot.docs.first.data();
      setState(() {
        _icController.text = clientData['ic'];
        _nameController.text = clientData['name'];
        _dobController.text = clientData['dob'];
        _phoneController.text = clientData['phone'];
        _emailController.text = clientData['email'];
        _addressController.text = clientData['address'];
        _cityController.text = clientData['city'];
        _postcodeController.text = clientData['postcode'];
        _gender = clientData['gender'];
        _religion = clientData['religion'];
        _race = clientData['race'];
        _status = clientData['status'];
        _state = clientData['state'];
      });
    }
  }

  void _saveClient() async {
    if (_formKey.currentState!.validate()) {
      if (widget.ic != null) {
        // Update existing client
        var clientDoc =
            FirebaseFirestore.instance.collection('clients').doc(widget.ic);
        await clientDoc.update({
          'ic': _icController.text,
          'name': _nameController.text,
          'dob': _dobController.text,
          'gender': _gender,
          'religion': _religion,
          'race': _race,
          'status': _status,
          'address': _addressController.text,
          'city': _cityController.text,
          'postcode': _postcodeController.text,
          'state': _state,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });
      } else {
        // Add new client
        await FirebaseFirestore.instance.collection('clients').add({
          'ic': _icController.text,
          'name': _nameController.text,
          'dob': _dobController.text,
          'gender': _gender,
          'religion': _religion,
          'race': _race,
          'status': _status,
          'address': _addressController.text,
          'city': _cityController.text,
          'postcode': _postcodeController.text,
          'state': _state,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client details saved successfully')),
      );
      Navigator.pop(context, _icController.text); // Return the new IC
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.ic != null ? 'Kemaskini Klien' : 'Daftar Klien Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _icController,
                decoration: InputDecoration(labelText: 'No Kad Pengenalan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter No Kad Pengenalan';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Nama';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Tarikh Lahir'),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _dobController.text =
                        date.toLocal().toString().split(' ')[0];
                  }
                },
                readOnly: true,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Jantina'),
                value: _gender,
                onChanged: (String? newValue) {
                  setState(() {
                    _gender = newValue;
                  });
                },
                items: <String>['Perempuan', 'Lelaki']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Jantina';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Agama'),
                value: _religion,
                onChanged: (String? newValue) {
                  setState(() {
                    _religion = newValue;
                  });
                },
                items: <String>['Hindu', 'Buddha', 'Islam']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Agama';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Kaum'),
                value: _race,
                onChanged: (String? newValue) {
                  setState(() {
                    _race = newValue;
                  });
                },
                items: _races.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Kaum';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status'),
                value: _status,
                onChanged: (String? newValue) {
                  setState(() {
                    _status = newValue;
                  });
                },
                items: _statuses.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Status';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Alamat';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'Bandar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Bandar';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _postcodeController,
                decoration: InputDecoration(labelText: 'Poskod'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Poskod';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Negeri'),
                value: _state,
                onChanged: (String? newValue) {
                  setState(() {
                    _state = newValue;
                  });
                },
                items: _states.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select Negeri';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'No Telefon'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter No Telefon';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Emel'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Emel';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveClient,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
