import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/packages/domain/package_model.dart';
import '../../features/batches/domain/batch_model.dart';

class ExportService {
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id');

  // ─── Excel Export ───
  static Future<void> exportToExcel(
    List<PackageModel> packages,
    BuildContext context,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Paket'];

    // Header row
    final headers = [
      'No',
      'Kode Tracking',
      'Nama Penerima',
      'No. Telepon',
      'Kota Tujuan',
      'Ukuran (cm)',
      'Status',
      'Tanggal Masuk',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data rows
    for (var i = 0; i < packages.length; i++) {
      final pkg = packages[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(pkg.trackingCode),
        TextCellValue(pkg.recipientName),
        TextCellValue(pkg.recipientPhone),
        TextCellValue(pkg.destinationCity),
        TextCellValue(pkg.dimensionsLabel ?? '-'),
        TextCellValue(pkg.currentStatus.label),
        TextCellValue(_dateFormat.format(pkg.createdAt)),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/resiqu_paket_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(filePath)], text: 'Data Paket ResiQu');
  }

  // ─── PDF Export ───
  static Future<void> exportToPdf(
    List<PackageModel> packages,
    BuildContext context,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ResiQu - Data Paket',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 4),
            pw.Text(
              'Dicetak: ${_dateFormat.format(DateTime.now())} · Total: ${packages.length} paket',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
            cellAlignments: {0: pw.Alignment.center},
            headers: ['No', 'Tracking', 'Penerima', 'Tujuan', 'Ukuran', 'Status', 'Tanggal'],
            data: List.generate(packages.length, (i) {
              final pkg = packages[i];
              return [
                '${i + 1}',
                pkg.trackingCode,
                pkg.recipientName,
                pkg.destinationCity,
                pkg.dimensionsLabel ?? '-',
                pkg.currentStatus.label,
                _dateFormat.format(pkg.createdAt),
              ];
            }),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'resiqu_paket.pdf');
  }

  // ─── Share to WhatsApp ───
  static Future<void> shareToWhatsApp(PackageModel pkg) async {
    final text = _buildShareText(pkg);
    final encoded = Uri.encodeComponent(text);
    final url = 'https://wa.me/?text=$encoded';
    await Share.shareUri(Uri.parse(url));
  }

  // ─── General Share ───
  static Future<void> shareGeneral(PackageModel pkg) async {
    final text = _buildShareText(pkg);
    await Share.share(text, subject: 'ResiQu - Info Paket ${pkg.trackingCode}');
  }

  static String _buildShareText(PackageModel pkg) {
    final dims = pkg.dimensionsLabel != null ? '\n📐 Ukuran: ${pkg.dimensionsLabel}' : '';
    return '''📦 *ResiQu - Info Paket*

🔢 Kode Tracking: *${pkg.trackingCode}*
👤 Penerima: ${pkg.recipientName}
📍 Tujuan: ${pkg.destinationCity}$dims
📊 Status: ${pkg.currentStatus.label}
📅 Tanggal: ${_dateFormat.format(pkg.createdAt)}

🔗 Lacak di: resiqu.app/tracking?code=${pkg.trackingCode}''';
  }

  // ─── Batch Excel Export ───
  static Future<void> exportBatchesToExcel(
    List<BatchModel> batches,
    BuildContext context,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Box Kontainer'];

    final headers = [
      'No',
      'Nama Box',
      'Kota Tujuan',
      'Status',
      'Jumlah Paket',
      'Dibuat Oleh',
      'Tanggal Dibuat',
    ];
    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    for (var i = 0; i < batches.length; i++) {
      final b = batches[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(b.name),
        TextCellValue(b.destinationCity),
        TextCellValue(b.status.label),
        IntCellValue(b.packageIds.length),
        TextCellValue(b.createdBy.split('@').first),
        TextCellValue(_dateFormat.format(b.createdAt)),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/resiqu_box_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(filePath)], text: 'Data Box ResiQu');
  }

  // ─── Batch PDF Export ───
  static Future<void> exportBatchesToPdf(
    List<BatchModel> batches,
    BuildContext context,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.portrait,
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ResiQu - Data Box Kontainer',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 4),
            pw.Text(
              'Dicetak: ${_dateFormat.format(DateTime.now())} · Total: ${batches.length} box',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
            cellAlignments: {0: pw.Alignment.center},
            headers: ['No', 'Nama Box', 'Tujuan', 'Status', 'Jml Paket', 'Tanggal'],
            data: List.generate(batches.length, (i) {
              final b = batches[i];
              return [
                '${i + 1}',
                b.name,
                b.destinationCity,
                b.status,
                '${b.packageIds.length}',
                _dateFormat.format(b.createdAt),
              ];
            }),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'resiqu_box.pdf');
  }
}
