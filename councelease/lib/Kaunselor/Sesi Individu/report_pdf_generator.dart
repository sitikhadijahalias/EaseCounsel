import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ReportPdfGenerator {
  static Future<File> generateReportPdf(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();
    final date = DateFormat.yMd().format(reportData['tarikh'].toDate());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('No Rujukan: ${reportData['no_rujukan']}'),
              pw.Text('Latarbelakang: ${reportData['latarbelakang']}'),
              pw.Text('Intervensi: ${reportData['intervensi']}'),
              pw.Text('Catatan: ${reportData['catatan']}'),
              pw.Text('Tarikh: $date'),
              pw.Text('Status: ${reportData['status']}'),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report_${reportData['no_rujukan']}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
