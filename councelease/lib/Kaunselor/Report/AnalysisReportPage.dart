import 'package:councelease/Kaunselor/Report/CaraHadirAnalysisChart.dart';
import 'package:councelease/Kaunselor/Report/KategoriKlienAnalysisChart.dart';
import 'package:councelease/Kaunselor/Report/ServiceTypeAnalysisChart.dart';
import 'package:flutter/material.dart';

class AnalysisReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Analisis"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ListTile(
            leading: Icon(Icons.description),
            title: Text(
                "Laporan Analisis Sesi Perkhidmatan Mengikut Jenis Perkhidmatan"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceTypeAnalysisChart(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.people),
            title:
                Text("Laporan Analisis Sesi Perkhidmatan Mengikut Cara Hadir"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaraHadirAnalysisChart(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category),
            title: Text(
                "Laporan Analisis Sesi Perkhidmatan Mengikut Kategori Klien"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KategoriKlienAnalysisChart(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
