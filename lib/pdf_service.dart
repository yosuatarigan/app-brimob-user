import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import '../models/user_model.dart';

class PdfService {
  static Future<Uint8List> generateCvPdf(UserModel user) async {
    final pdf = pw.Document();

    // Load fonts
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Load profile image if available
    pw.ImageProvider? profileImage;
    if (user.photoUrl != null) {
      try {
        final response = await HttpClient().getUrl(Uri.parse(user.photoUrl!));
        final imageResponse = await response.close();
        final imageBytes = await consolidateHttpClientResponseBytes(imageResponse);
        profileImage = pw.MemoryImage(imageBytes);
      } catch (e) {
        profileImage = null;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - sama persis seperti contoh
              _buildHeader(font, fontBold),
              pw.SizedBox(height: 15),
              
              // Top section - Photo + Basic Info (sejajar horizontal)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Photo - di kiri
                  pw.Container(
                    width: 100,
                    height: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                    ),
                    child: profileImage != null
                        ? pw.Image(profileImage, fit: pw.BoxFit.cover)
                        : pw.Container(color: PdfColors.red100),
                  ),
                  
                  pw.SizedBox(width: 50),
                  
                  // Basic info - di kanan foto
                  pw.Container(
                    width: 350,
                    child: _buildBasicInfoTable(user, font, fontBold),
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              
              // Three sections in a row - 3 kolom sejajar
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // I. Pendidikan Kepolisian
                  pw.Container(
                    width: 160,
                    child: _buildSectionTable(
                      'I. Pendidikan Kepolisian',
                      ['Tingkat', 'Tahun'],
                      user.pendidikanKepolisian.map((item) => [item.tingkat, item.tahun.toString()]).toList(),
                      font,
                      fontBold,
                      columnWidth: 160,
                    ),
                  ),
                  
                  pw.SizedBox(width: 10),
                  
                  // II. Pendidikan Umum
                  pw.Container(
                    width: 200,
                    child: _buildSectionTable(
                      'II. Pendidikan Umum',
                      ['Tingkat', 'Nama Institusi', 'Tahun'],
                      user.pendidikanUmum.map((item) => [item.tingkat, item.namaInstitusi, item.tahun.toString()]).toList(),
                      font,
                      fontBold,
                      columnWidth: 200,
                      isThreeColumn: true,
                    ),
                  ),
                  
                  pw.SizedBox(width: 10),
                  
                  // III. Riwayat Pangkat
                  pw.Container(
                    width: 155,
                    child: _buildSectionTable(
                      'III. Riwayat Pangkat',
                      ['Pangkat', 'TMT'],
                      user.riwayatPangkat.map((item) => [item.pangkat, _formatDateTMT(item.tmt)]).toList(),
                      font,
                      fontBold,
                      columnWidth: 155,
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 15),
              
              // Bottom sections - 2 kolom
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // IV. Riwayat Jabatan - kolom kiri (lebih lebar)
                  pw.Container(
                    width: 320,
                    child: _buildSectionTable(
                      'IV. Riwayat Jabatan',
                      ['Jabatan', 'TMT'],
                      user.riwayatJabatan.map((item) => [item.jabatan, _formatDateTMT(item.tmt)]).toList(),
                      font,
                      fontBold,
                      columnWidth: 320,
                    ),
                  ),
                  
                  pw.SizedBox(width: 15),
                  
                  // Right column - V, VI, VII tersusun vertikal
                  pw.Container(
                    width: 200,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // V. Pendidikan Pengembangan & Pelatihan
                        _buildSectionTable(
                          'V. Pendidikan Pengembangan & Pelatihan',
                          ['Dikbang', 'TMT'],
                          user.pendidikanPelatihan.map((item) => [item.dikbang, _formatDateTMT(item.tmt)]).toList(),
                          font,
                          fontBold,
                          columnWidth: 200,
                        ),
                        pw.SizedBox(height: 10),
                        
                        // VI. Tanda Kehormatan
                        _buildSectionTable(
                          'VI. Tanda Kehormatan',
                          ['Tanda Kehormatan', 'TMT'],
                          user.tandaKehormatan.map((item) => [item.tandaKehormatan, _formatDateTMT(item.tmt)]).toList(),
                          font,
                          fontBold,
                          columnWidth: 200,
                        ),
                        pw.SizedBox(height: 10),
                        
                        // VII. Kemampuan Bahasa
                        _buildSectionTable(
                          'VII. Kemampuan Bahasa',
                          ['Bahasa', 'Status'],
                          user.kemampuanBahasa.map((item) => [item.bahasa, item.status]).toList(),
                          font,
                          fontBold,
                          columnWidth: 200,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 15),
              
              // VIII. Penugasan Luar Struktur - full width di bawah
              _buildPenugasanLuarStrukturSection(user, font, fontBold),
              
              pw.SizedBox(height: 135),
              
              // Footer signature
              _buildFooterSignature(user, font, fontBold),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MARKAS BESAR',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.Text(
          'KEPOLISIAN NEGARA REPUBLIK INDONESIA',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.Text(
          'STAF SUMBER DAYA MANUSIA',
          style: pw.TextStyle(font: fontBold, fontSize: 12),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: 250,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'DAFTAR RIWAYAT HIDUP',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicInfoTable(UserModel user, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Nama Lengkap', user.fullName, font, fontBold),
        _buildInfoRow('Pangkat/NRP', '${user.rank} / ${user.nrp}', font, fontBold),
        _buildInfoRow('Jabatan/TMT', '${user.jabatan}${user.jabatanTmt != null ? ' (${user.formattedJabatanTmt})' : ''}', font, fontBold),
        _buildInfoRow('Lama Jabatan', user.lamaJabatan, font, fontBold),
        _buildInfoRow('Tempat, Tanggal Lahir', user.tempatTanggalLahir, font, fontBold),
        _buildInfoRow('Agama', user.agama ?? '', font, fontBold),
        _buildInfoRow('Suku', user.suku ?? '', font, fontBold),
        _buildInfoRow('Status Personel', user.statusPersonel ?? '', font, fontBold),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
          pw.Container(
            width: 220,
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTable(
    String title, 
    List<String> headers, 
    List<List<String>> data, 
    pw.Font font, 
    pw.Font fontBold, 
    {double? columnWidth, bool isThreeColumn = false}
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Blue header
        pw.Container(
          width: columnWidth ?? double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: const PdfColor(0.2, 0.4, 0.7),
          child: pw.Text(
            title,
            style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
          ),
        ),
        // Table
        pw.Container(
          width: columnWidth ?? double.infinity,
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: isThreeColumn ? {
              0: const pw.FlexColumnWidth(1.5),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
            } : {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor(0.8, 0.8, 0.8)),
                children: headers.map((header) => 
                  pw.Container(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(font: fontBold, fontSize: 8),
                    ),
                  ),
                ).toList(),
              ),
              // Data rows
              ...data.map((row) => pw.TableRow(
                children: row.map((cell) => 
                  pw.Container(
                    padding: const pw.EdgeInsets.all(3),
                    child: pw.Text(
                      cell,
                      style: pw.TextStyle(font: font, fontSize: 8),
                    ),
                  ),
                ).toList(),
              )),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBottomSections(UserModel user, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // VII. Kemampuan Bahasa - full width
        _buildSectionTable(
          'VII. Kemampuan Bahasa',
          ['Bahasa', 'Status'],
          user.kemampuanBahasa.map((item) => [item.bahasa, item.status]).toList(),
          font,
          fontBold,
        ),
        pw.SizedBox(height: 10),
        
        // VIII. Penugasan Luar Struktur - full width
        _buildPenugasanLuarStrukturSection(user, font, fontBold),
      ],
    );
  }

  static pw.Widget _buildPenugasanLuarStrukturSection(UserModel user, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          color: const PdfColor(0.2, 0.4, 0.7),
          child: pw.Text(
            'VIII. Penugasan Luar Struktur',
            style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
          ),
        ),
        user.penugasanLuarStruktur.isNotEmpty
            ? pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColor(0.8, 0.8, 0.8)),
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text('Penugasan', style: pw.TextStyle(font: fontBold, fontSize: 8)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text('Lokasi', style: pw.TextStyle(font: fontBold, fontSize: 8)),
                      ),
                    ],
                  ),
                  // Data rows
                  ...user.penugasanLuarStruktur.map((item) => pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(item.penugasan, style: pw.TextStyle(font: font, fontSize: 8)),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        child: pw.Text(item.lokasi, style: pw.TextStyle(font: font, fontSize: 8)),
                      ),
                    ],
                  )),
                ],
              )
            : pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 0.5),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Data penugasan luar struktur tidak ditemukan',
                    style: pw.TextStyle(font: font, fontSize: 8),
                  ),
                ),
              ),
      ],
    );
  }

  static pw.Widget _buildFooterSignature(UserModel user, pw.Font font, pw.Font fontBold) {
    final now = DateTime.now();
    final dateString = 'Jakarta, ${now.day.toString().padLeft(2, '0')} - ${now.month.toString().padLeft(2, '0')} - ${now.year}';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              dateString,
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
            pw.Text(
              user.jabatan.toUpperCase(),
              style: pw.TextStyle(font: fontBold, fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
            pw.SizedBox(height: 40), // Space for signature
            pw.Text(
              user.fullName.toUpperCase(),
              style: pw.TextStyle(font: fontBold, fontSize: 9),
            ),
            pw.Text(
              '${user.rank.toUpperCase()} NRP ${user.nrp}',
              style: pw.TextStyle(font: fontBold, fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatDateTMT(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Method untuk save PDF ke device
  static Future<void> savePdfToDevice(UserModel user) async {
    final pdfData = await generateCvPdf(user);
    final fileName = 'CV_${user.fullName.replaceAll(' ', '_')}_${user.nrp}.pdf';
    
    await Printing.sharePdf(
      bytes: pdfData,
      filename: fileName,
    );
  }

  // Method untuk print PDF
  static Future<void> printPdf(UserModel user) async {
    final pdfData = await generateCvPdf(user);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }
}