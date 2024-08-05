import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JanjiTemu extends StatefulWidget {
  @override
  _JanjiTemuState createState() => _JanjiTemuState();
}

class _JanjiTemuState extends State<JanjiTemu> {
  TextEditingController _icController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _postcodeController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _siblingsController = TextEditingController();
  TextEditingController _birthOrderController = TextEditingController();
  TextEditingController _emergencyContactNameController =
      TextEditingController();
  TextEditingController _relationshipController = TextEditingController();
  TextEditingController _emergencyContactPhoneController =
      TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedReligion;
  String? _selectedRace;
  String? _selectedStatus;
  String? _selectedState;

  Future<void> _fetchCustomerDetails(String ic) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      print("Fetching details for IC: $ic");
      var snapshot = await firestore
          .collection('appointments')
          .where('ic', isEqualTo: ic)
          .get();
      if (snapshot.docs.isNotEmpty) {
        var appointment = snapshot.docs.first.data();
        print("Appointment data found: $appointment");
        setState(() {
          _nameController.text = appointment['name'] ?? '';
          _addressController.text = appointment['address'] ?? '';
          _cityController.text = appointment['city'] ?? '';
          _postcodeController.text = appointment['postcode'] ?? '';
          _phoneController.text = appointment['phone'] ?? '';
          _emailController.text = appointment['email'] ?? '';
          _selectedDate = appointment['birthDate'] != null
              ? (appointment['birthDate'] as Timestamp).toDate()
              : null;
          _selectedGender = appointment['gender'];
          _selectedReligion = appointment['religion'];
          _selectedRace = appointment['race'];
          _selectedStatus = appointment['status'];
          _selectedState = appointment['state'];
          _siblingsController.text = appointment['siblings'] ?? '';
          _birthOrderController.text = appointment['birthOrder'] ?? '';
          _emergencyContactNameController.text =
              appointment['emergencyContactName'] ?? '';
          _relationshipController.text = appointment['relationship'] ?? '';
          _emergencyContactPhoneController.text =
              appointment['emergencyContactPhone'] ?? '';
        });
      } else {
        print('No appointment found for the given IC');
      }
    } catch (e) {
      print("Error fetching appointment details: $e");
    }
  }

  void _navigateToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JanjiTemu1(
          ic: _icController.text,
          name: _nameController.text,
          address: _addressController.text,
          city: _cityController.text,
          postcode: _postcodeController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          birthDate: _selectedDate,
          gender: _selectedGender,
          religion: _selectedReligion,
          race: _selectedRace,
          status: _selectedStatus,
          state: _selectedState,
          siblings: _siblingsController.text,
          birthOrder: _birthOrderController.text,
          emergencyContactName: _emergencyContactNameController.text,
          relationship: _relationshipController.text,
          emergencyContactPhone: _emergencyContactPhoneController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(
          "Borang Temujanji Sesi",
          style: TextStyle(
            color: Colors.black, // Set text color of the app bar title
            fontWeight: FontWeight.bold, // Set font weight of the app bar title
            fontSize: 20, // Set font size of the app bar title
          ),
        ),
        backgroundColor: Color(0xFFFFCC80),
        // Set background color of the app bar
        iconTheme: IconThemeData(
            color: Colors.black), // Set color of the icons (back button, etc.)
        centerTitle: true, // Center align the title
        elevation: 0, // Remove the shadow under the app bar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Maklumat Peribadi Klien",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'CuteFont',
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _icController,
              label: "No Kad Pengenalan",
              icon: Icons.search,
              onIconPressed: () {
                print("Search button pressed");
                if (_icController.text.isNotEmpty) {
                  print("IC entered: ${_icController.text}");
                  _fetchCustomerDetails(_icController.text);
                }
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _nameController,
              label: "Nama",
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Tarikh Lahir",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.orange, width: 2.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
              ),
              readOnly: true,
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              controller: TextEditingController(
                text: _selectedDate != null
                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                    : "",
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text("Jantina:", style: TextStyle(fontFamily: 'CuteFont')),
                SizedBox(width: 10),
                Row(
                  children: [
                    Text("Lelaki"),
                    Radio(
                      value: "Lelaki",
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value.toString();
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Text("Perempuan"),
                    Radio(
                      value: "Perempuan",
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value.toString();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildDropdown(
              label: "Agama",
              value: _selectedReligion,
              items: [
                "Islam",
                "Kristian",
                "Buddha",
                "Hindu",
                "Agama Lain",
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedReligion = newValue as String?;
                });
              },
            ),
            SizedBox(height: 10),
            _buildDropdown(
              label: "Kaum",
              value: _selectedRace,
              items: [
                "Melayu",
                "Cina",
                "India",
                "Bumiputera Lain (Sabah)",
                "Bumiputera Lain (Sarawak)",
                "Lain-Lain",
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedRace = newValue as String?;
                });
              },
            ),
            SizedBox(height: 10),
            _buildDropdown(
              label: "Status Perkahwinan",
              value: _selectedStatus,
              items: [
                "Bujang",
                "Berkahwin",
                "Duda",
                "Janda",
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue as String?;
                });
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _addressController,
              label: "Alamat",
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _cityController,
              label: "Bandar",
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _postcodeController,
              label: "Poskod",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _buildDropdown(
              label: "Negeri",
              value: _selectedState,
              items: [
                "Johor",
                "Kedah",
                "Kelantan",
                "Melaka",
                "Negeri Sembilan",
                "Pahang",
                "Perak",
                "Perlis",
                "Pulau Pinang",
                "Sabah",
                "Sarawak",
                "Selangor",
                "Terengganu",
                "Wilayah Persekutuan Kuala Lumpur",
                "Wilayah Persekutuan Labuan",
                "Wilayah Persekutuan Putrajaya",
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedState = newValue as String?;
                });
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _phoneController,
              label: "No Telefon",
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _emailController,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _siblingsController,
              label: "Bilangan Adik Beradik",
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _birthOrderController,
              label: "Kedudukan Dalam Keluarga",
            ),
            SizedBox(height: 20),
            Text(
              "Maklumat Untuk Dihubungi Ketika Kecemasan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'CuteFont',
              ),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _emergencyContactNameController,
              label: "Nama Untuk Dihubungi",
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _relationshipController,
              label: "Hubungan",
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _emergencyContactPhoneController,
              label: "No Telefon",
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _navigateToNextPage,
              child: Text(
                "Seterusnya",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CuteFont',
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xFFFFCC80), // Changed backgroundColor to primary
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                shadowColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    VoidCallback? onIconPressed,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.orange, width: 2.0),
        ),
        suffixIcon: icon != null
            ? IconButton(
                icon: Icon(
                  icon,
                  color: Color(0xFFFFCC80),
                ),
                onPressed: onIconPressed,
              )
            : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.orange, width: 2.0),
        ),
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class JanjiTemu1 extends StatefulWidget {
  final String ic;
  final String name;
  final String address;
  final String city;
  final String postcode;
  final String phone;
  final String email;
  final DateTime? birthDate;
  final String? gender;
  final String? religion;
  final String? race;
  final String? status;
  final String? state;
  final String siblings;
  final String birthOrder;
  final String emergencyContactName;
  final String relationship;
  final String emergencyContactPhone;

  JanjiTemu1({
    required this.ic,
    required this.name,
    required this.address,
    required this.city,
    required this.postcode,
    required this.phone,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.religion,
    required this.race,
    required this.status,
    required this.state,
    required this.siblings,
    required this.birthOrder,
    required this.emergencyContactName,
    required this.relationship,
    required this.emergencyContactPhone,
  });

  @override
  _JanjiTemu1State createState() => _JanjiTemu1State();
}

class _JanjiTemu1State extends State<JanjiTemu1> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedAppointmentDate;
  TimeOfDay? _selectedAppointmentTime;
  String? _selectedCounselor;
  List<String> _counselors = [];

  @override
  void initState() {
    super.initState();
    _fetchCounselors();
  }

  void _fetchCounselors() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      var snapshot = await firestore.collection('councillors').get();
      if (snapshot.docs.isNotEmpty) {
        List<String> names = [];
        snapshot.docs.forEach((doc) {
          var data = doc.data();
          names.add(data['name']);
        });
        setState(() {
          _counselors = names;
        });
      } else {
        print('No counselors found in Firestore');
      }
    } catch (e) {
      print('Error fetching counselors: $e');
    }
  }

  Future<void> _saveAppointmentDetails() async {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      Timestamp? appointmentTimestamp;
      if (_selectedAppointmentDate != null &&
          _selectedAppointmentTime != null) {
        DateTime combinedDateTime = DateTime(
          _selectedAppointmentDate!.year,
          _selectedAppointmentDate!.month,
          _selectedAppointmentDate!.day,
          _selectedAppointmentTime!.hour,
          _selectedAppointmentTime!.minute,
        );
        appointmentTimestamp = Timestamp.fromDate(combinedDateTime);
      }

      Map<String, dynamic> appointmentDetails = {
        'ic': widget.ic,
        'name': widget.name,
        'address': widget.address,
        'city': widget.city,
        'postcode': widget.postcode,
        'phone': widget.phone,
        'email': widget.email,
        'birthDate': widget.birthDate != null
            ? Timestamp.fromDate(widget.birthDate!)
            : null,
        'gender': widget.gender,
        'religion': widget.religion,
        'race': widget.race,
        'status': widget.status,
        'state': widget.state,
        'siblings': widget.siblings,
        'birthOrder': widget.birthOrder,
        'emergencyContactName': widget.emergencyContactName,
        'relationship': widget.relationship,
        'emergencyContactPhone': widget.emergencyContactPhone,
        'appointmentTimestamp': appointmentTimestamp,
        'counselor': _selectedCounselor,
      };

      firestore.collection('appointments').add(appointmentDetails).then((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            // ignore: prefer_const_constructors
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Text(
                  "Berjaya",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  "Tempahan Temu Janji anda telah berjaya dihantar!",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/');
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFCC80), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save appointment details")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 253, 253),
      appBar: AppBar(
        title: Text(
          "Maklumat Temujanji",
          style: TextStyle(
            color: Colors.black, // Set text color of the app bar title
            fontWeight: FontWeight.bold, // Set font weight of the app bar title
            fontSize: 20, // Set font size of the app bar title
          ),
        ),
        backgroundColor:
            Color(0xFFFFCC80), // Set background color of the app bar
        iconTheme: IconThemeData(
            color: Colors.black), // Set color of the icons (back button, etc.)
        centerTitle: true, // Center align the title
        elevation: 0, // Remove the shadow under the app bar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Pilih Tarikh Temujanji",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Tarikh Temujanji",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (_selectedAppointmentDate == null) {
                    return 'Sila pilih tarikh temujanji';
                  }
                  return null;
                },
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null &&
                      pickedDate != _selectedAppointmentDate) {
                    setState(() {
                      _selectedAppointmentDate = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _selectedAppointmentDate != null
                      ? "${_selectedAppointmentDate!.day}/${_selectedAppointmentDate!.month}/${_selectedAppointmentDate!.year}"
                      : "",
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Pilih Waktu Temujanji",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Waktu Temujanji",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (_selectedAppointmentTime == null) {
                    return 'Sila pilih waktu temujanji';
                  }
                  return null;
                },
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null &&
                      pickedTime != _selectedAppointmentTime) {
                    setState(() {
                      _selectedAppointmentTime = pickedTime;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _selectedAppointmentTime != null
                      ? _selectedAppointmentTime!.format(context)
                      : "",
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Pilih Kaunselor",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: "Kaunselor",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.orange, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
                value: _selectedCounselor,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCounselor = newValue as String?;
                  });
                },
                items: _counselors.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sila pilih kaunselor';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAppointmentDetails,
                child: Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CuteFont',
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFCC80),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  shadowColor: Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
