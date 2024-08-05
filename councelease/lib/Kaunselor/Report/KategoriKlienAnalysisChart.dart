import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class KategoriKlienAnalysisChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Analisis Kategori Klien"),
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

          // Count the occurrences of each 'kategoriKlien' type
          Map<String, int> kategoriKlienCounts = {
            'Individu': 0,
            'Kelompok': 0,
          };

          for (var doc in snapshot.data!.docs) {
            String? kategoriKlien = doc['kategoriKlien'];
            if (kategoriKlien != null &&
                kategoriKlienCounts.containsKey(kategoriKlien)) {
              kategoriKlienCounts[kategoriKlien] =
                  kategoriKlienCounts[kategoriKlien]! + 1;
            }
          }

          // Prepare data for the bar chart
          List<ChartData> chartData = kategoriKlienCounts.entries
              .map(
                (entry) => ChartData(
                  x: entry.key,
                  y: entry.value.toDouble(),
                ),
              )
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SfCartesianChart(
              // Title of the chart
              title: ChartTitle(
                text: 'Jumlah Janji Temu Mengikut Kategori Klien',
                alignment: ChartAlignment.center,
              ),
              // Legend configuration
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              // Series configuration
              series: <ChartSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  // Customize the appearance of the columns
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
              // Tooltip behavior
              tooltipBehavior: TooltipBehavior(
                enable: true, // Enable tooltip
              ),
              // Customizing the category axis to show specific labels
              primaryXAxis: CategoryAxis(
                labelPlacement: LabelPlacement.onTicks,
                majorGridLines: MajorGridLines(width: 0),
                labelStyle: TextStyle(fontSize: 12),
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
