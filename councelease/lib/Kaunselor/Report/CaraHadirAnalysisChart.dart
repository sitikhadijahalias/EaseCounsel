import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CaraHadirAnalysisChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Analisis Cara Hadir"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Chart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tiada data ditemui."));
          }

          // Count the occurrences of each 'kaedahSesi' type
          Map<String, int> caraHadirCounts = {
            'Bersemuka': 0,
            'Atas Talian': 0,
          };

          for (var doc in snapshot.data!.docs) {
            String? caraHadir = doc['kaedahSesi'];
            if (caraHadir != null && caraHadirCounts.containsKey(caraHadir)) {
              caraHadirCounts[caraHadir] = caraHadirCounts[caraHadir]! + 1;
            }
          }

          // Prepare data for the pie chart
          List<ChartData> chartData = caraHadirCounts.entries
              .map(
                (entry) => ChartData(
                  x: entry.key,
                  y: entry.value.toDouble(),
                ),
              )
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SfCircularChart(
              // Title of the chart
              title: ChartTitle(
                text: 'Jumlah Janji Temu Mengikut Cara Hadir',
                alignment: ChartAlignment.center,
              ),
              // Legend configuration
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              // Series configuration
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  // Customize the appearance of the pie segments
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
              // Tooltip behavior
              tooltipBehavior: TooltipBehavior(
                enable: true, // Enable tooltip
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData({required this.x, required this.y});
}
