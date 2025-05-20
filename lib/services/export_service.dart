import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/note.dart';

class ExportService {
  // Singleton pattern
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<void> exportAsTxt(Note note) async {
    if (!kIsWeb) {
      // For non-web platforms, implement platform-specific export
      throw UnimplementedError('Text export is only implemented for web platform');
    }

    final content = _formatNoteForTxt(note);
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '${_sanitizeFilename(note.title)}.txt')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> exportAsPdf(Note note) async {
    if (!kIsWeb) {
      // For non-web platforms, implement platform-specific export
      throw UnimplementedError('PDF export is only implemented for web platform');
    }

    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                note.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Created: ${DateFormat('MMM d, yyyy').format(note.createdAt)}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                'Last modified: ${DateFormat('MMM d, yyyy').format(note.updatedAt)}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text(
                note.content,
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', '${_sanitizeFilename(note.title)}.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  String _formatNoteForTxt(Note note) {
    final buffer = StringBuffer();
    buffer.writeln(note.title);
    buffer.writeln('Created: ${DateFormat('MMM d, yyyy').format(note.createdAt)}');
    buffer.writeln('Last modified: ${DateFormat('MMM d, yyyy').format(note.updatedAt)}');
    buffer.writeln('---');
    buffer.writeln();
    buffer.write(note.content);
    return buffer.toString();
  }

  String _sanitizeFilename(String filename) {
    // Replace invalid filename characters with underscores
    return filename
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
  }
}
