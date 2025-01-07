import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void exportPdf(List<String> contentList) async {
  final pdf = pw.Document();

  const double pageWidth = 595.0;
  const double pageHeight = 842.0;
  const double margin = 40.0;
  const double usableWidth = pageWidth - margin * 2;
  const double usableHeight = pageHeight - margin * 2;

  final textStyle = pw.TextStyle(fontSize: 14);
  final lineHeight = 20.0;

  double calculateContentHeight(String text) {
    final lines = (text.length * 14) / usableWidth;
    return lines.ceil() * lineHeight;
  }

  double currentHeight = 0.0;
  List<pw.Widget> currentPageWidgets = [];

  for (String content in contentList) {
    final contentHeight = calculateContentHeight(content);

    if (currentHeight + contentHeight > usableHeight) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(children: currentPageWidgets),
          margin: pw.EdgeInsets.all(margin),
        ),
      );
      currentPageWidgets = [];
      currentHeight = 0.0;
    }

    currentPageWidgets.add(pw.Text(content, style: textStyle));
    currentHeight += contentHeight;
  }

  if (currentPageWidgets.isNotEmpty) {
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(children: currentPageWidgets),
        margin: pw.EdgeInsets.all(margin),
      ),
    );
  }

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/dynamic_content.pdf");
  await file.writeAsBytes(await pdf.save());
  await Printing.sharePdf(
      bytes: await pdf.save(), filename: 'dynamic_content.pdf');
}

class PdfApi {
  static Future<File> generateStudentPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Academic Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            CustomSection('Student Details', [
              Row('Name', data['name']),
              Row('Email', data['email']),
              Row('Registration Number', data['regno']),
              Row('Academic Year', data['academicyear']),
              Row('Admission Number', data['admno']),
              Row('Date of Admission', data['admdate']),
            ]),
            CustomSection('Department Details', [
              Row('Department', data['department']),
              Row('HOD', data['hod']),
            ]),
            CustomSection("Father's Details", [
              Row('Name', data['fathername']),
              Row('Occupation', data['fatherjob']),
              Row('Phone', data['fatherphone']),
            ]),
            CustomSection("Mother's Details", [
              Row('Name', data['mothername']),
              Row('Occupation', data['motherjob']),
              Row('Phone', data['motherphone']),
            ]),
            CustomSection('Academic Performance', [
              Row('Score', '${data['score'] ?? 0}/1200'),
              Row('Percentage', '${data['percentage'] ?? 0}%'),
              Row('Grade', data['grade']),
              Row('Status', data['status']),
            ]),
            pw.Text(
              'Generated by School Management Application.',
              style: pw.TextStyle(
                fontSize: 12,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
          ],
        );
      },
    ));

    return saveDocument(name: 'student_details.pdf', pdf: pdf);
  }

  static pw.Widget CustomSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blueGrey300, width: 1),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(children: children),
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget Row(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey600,
            ),
          ),
          pw.Text(
            value ?? 'N/A',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.blueGrey800,
            ),
          ),
        ],
      ),
    );
  }

  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
