import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:councelease/Main%20Page/janjitemu.dart';
import 'package:councelease/Main%20Page/logkaunselor.dart';
import 'package:councelease/Main%20Page/logketuajabatan.dart';
import 'package:councelease/Main%20Page/penilaiansesi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Add this line
      title: 'CouncelEase',
      theme: ThemeData(
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFFF971D),
        ),
        fontFamily: 'Lato-Bold',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CouncelEase(),
        '/janjiTemu': (context) => JanjiTemu(),
        '/penilaianSesi': (context) => PenilaianSesi(),
        '/logKaunselor': (context) => LogMasukKaunselor(),
        '/logKetuaJabatan': (context) => LogMasukKetuaJabatan(),
      },
    );
  }
}

class CouncelEase extends StatefulWidget {
  CouncelEase({Key? key}) : super(key: key);

  @override
  _CouncelEaseState createState() => _CouncelEaseState();
}

class _CouncelEaseState extends State<CouncelEase> {
  @override
  void initState() {
    super.initState();
  }

  BoxDecoration buttonDecoration() {
    return BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC80),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 0),
              Image.asset(
                'assets/Counsel.png',
                width: 400,
                height: 200,
              ),
              SizedBox(height: 0),
              Text(
                "Aplikasi Pengurusan\nPerkhidmatan Kaunseling",
                style: TextStyle(
                  color: Color.fromARGB(255, 10, 10, 10),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato-Black',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: buttonDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/janjiTemu');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.white; // Solid beige color
                          },
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        "Janji Temu Kaunselor",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold), // Text color black
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: buttonDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/penilaianSesi');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.white; // Solid beige color
                          },
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        "Penilaian Sesi",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold), // Text color black
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: buttonDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/logKaunselor');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.white; // Solid beige color
                          },
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        "Log Masuk Kaunselor",
                        style:
                            TextStyle(color: Colors.black), // Text color black
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: buttonDecoration(),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/logKetuaJabatan');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            return Colors.white; // Solid beige color
                          },
                        ),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        "Log Masuk Ketua Jabatan",
                        style:
                            TextStyle(color: Colors.black), // Text color black
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
