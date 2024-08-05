import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Syncfusion Charts Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ServiceTypeAnalysisChart(),
    );
  }
}

class ServiceTypeAnalysisChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sesi Perkhidmatan"),
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

          // Count the occurrences of each 'perkhidmatan' type
          Map<String, int> perkhidmatanCounts = {
            'Kaunseling Individu': 0,
            'Kaunseling Kelompok': 0,
            'Kaunseling Perkahwinan': 0,
            'Kaunseling Keluarga': 0,
          };

          for (var doc in snapshot.data!.docs) {
            String? perkhidmatan = doc['perkhidmatan'];
            if (perkhidmatan != null &&
                perkhidmatanCounts.containsKey(perkhidmatan)) {
              perkhidmatanCounts[perkhidmatan] =
                  perkhidmatanCounts[perkhidmatan]! + 1;
            }
          }

          // Prepare data for the radial bar chart
          List<ChartData> chartData = perkhidmatanCounts.entries
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
                text: 'Jumlah Janji Temu Mengikut Jenis Perkhidmatan',
                alignment: ChartAlignment.center,
              ),
              // Legend configuration
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              // Series configuration
              series: <CircularSeries>[
                RadialBarSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  cornerStyle: CornerStyle.bothCurve,
                  maximumValue: 10, // Adjust according to your data range
                ),
              ],
              // Tooltip behavior
              tooltipBehavior: TooltipBehavior(
                enable: true, // Enable tooltip
              ),
              // Hide the radial axis labels (like 1.0, 2.0, etc.)
              //  annotations: <CircularChartAnnotation>[
              // CircularChartAnnotation(
              //widget:
              // Container(), // Empty container to remove default labels
              // ),
              //],
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
