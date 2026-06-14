import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/cv_builder_models.dart';

class CvPdfDownloadService {
  static const MethodChannel _downloadChannel =
      MethodChannel('italir_pothe/downloads');

  Future<String> downloadCreatedCv({
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) async {
    final List<int> pdfBytes = await _buildPdfBytes(
      document: document,
      template: template,
    );

    return _savePdfToDevice(
      fileName: _safeFileName(document.title),
      bytes: Uint8List.fromList(pdfBytes),
    );
  }

  Future<List<int>> _buildPdfBytes({
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) async {
    final PdfDocument pdfDocument = PdfDocument();
    pdfDocument.pageSettings.size = PdfPageSize.a4;
    pdfDocument.pageSettings.margins.all = 36;

    final Uint8List regularFontBytes = await _fontBytes(
      'assets/fonts/Poppins-Regular.ttf',
    );
    final Uint8List mediumFontBytes = await _fontBytes(
      'assets/fonts/Poppins-SemiBold.ttf',
    );
    final Uint8List boldFontBytes = await _fontBytes(
      'assets/fonts/Poppins-Bold.ttf',
    );

    final PdfFont titleFont = PdfTrueTypeFont(boldFontBytes, 22);
    final PdfFont subtitleFont = PdfTrueTypeFont(regularFontBytes, 10);
    final PdfFont sectionFont = PdfTrueTypeFont(boldFontBytes, 13);
    final PdfFont labelFont = PdfTrueTypeFont(mediumFontBytes, 9);
    final PdfFont valueFont = PdfTrueTypeFont(regularFontBytes, 10);

    final PdfColor themeColor = _hexToPdfColor(document.themeColor);
    final PdfBrush themeBrush = PdfSolidBrush(themeColor);
    final PdfBrush textBrush = PdfBrushes.black;
    final PdfBrush secondaryBrush = PdfSolidBrush(PdfColor(88, 98, 112));
    final PdfPen dividerPen = PdfPen(themeColor, width: 1.2);

    PdfPage page = pdfDocument.pages.add();
    double y = 0;
    final Size pageSize = page.getClientSize();
    final double contentWidth = pageSize.width;
    Uint8List? photoBytes = await _loadPhotoBytes(
      _findPhotoUrl(document: document, template: template),
    );

    if (photoBytes != null) {
      try {
        page.graphics.drawImage(
          PdfBitmap(photoBytes),
          Rect.fromLTWH(contentWidth - 82, 0, 82, 82),
        );
      } catch (_) {
        photoBytes = null;
      }
    }

    final double headerTextWidth =
        photoBytes == null ? contentWidth : contentWidth - 96;

    void ensureSpace(double height) {
      if (y + height <= pageSize.height) return;
      page = pdfDocument.pages.add();
      y = 0;
    }

    void drawWrappedText(
      String text,
      PdfFont font,
      PdfBrush brush, {
      double indent = 0,
      double? maxWidth,
      double bottomGap = 4,
      double lineGap = 2,
    }) {
      final double availableWidth = maxWidth ?? contentWidth - indent;
      final List<String> lines = _wrapText(
        text: text,
        font: font,
        maxWidth: availableWidth,
      );
      final double lineHeight = font.measureString('Ag').height + lineGap;

      for (final String line in lines) {
        ensureSpace(lineHeight + bottomGap);
        page.graphics.drawString(
          line,
          font,
          brush: brush,
          bounds: Rect.fromLTWH(indent, y, availableWidth, lineHeight),
        );
        y += lineHeight;
      }

      y += bottomGap;
    }

    void drawSectionTitle(String title) {
      ensureSpace(34);
      drawWrappedText(
        title.toUpperCase(),
        sectionFont,
        themeBrush,
        bottomGap: 3,
      );
      page.graphics.drawLine(dividerPen, Offset(0, y), Offset(contentWidth, y));
      y += 10;
    }

    drawWrappedText(
      document.title,
      titleFont,
      themeBrush,
      maxWidth: headerTextWidth,
      bottomGap: 2,
    );
    final String subtitle = document.templateTitle ?? template.title;
    if (subtitle.trim().isNotEmpty) {
      drawWrappedText(
        subtitle,
        subtitleFont,
        secondaryBrush,
        maxWidth: headerTextWidth,
        bottomGap: 16,
      );
    } else {
      y += 14;
    }

    if (photoBytes != null && y < 96) {
      y = 96;
    }

    final Set<String> renderedSections = <String>{};
    for (final CvTemplateSectionModel section in template.schema.sections) {
      final Map<String, dynamic> sectionData = _sectionData(
        document.formData,
        section.key,
      );
      if (sectionData.isEmpty) continue;

      renderedSections.add(section.key);
      bool sectionTitleDrawn = false;

      for (final CvTemplateFieldModel field in section.fields) {
        final dynamic rawValue = sectionData[field.key];
        final String value = _displayValue(rawValue, field);
        if (value.isEmpty) continue;

        if (!sectionTitleDrawn) {
          drawSectionTitle(section.title.isNotEmpty ? section.title : section.key);
          sectionTitleDrawn = true;
        }

        drawWrappedText(field.label, labelFont, secondaryBrush, bottomGap: 0);
        drawWrappedText(value, valueFont, textBrush, bottomGap: 8);
      }
    }

    for (final MapEntry<String, dynamic> sectionEntry in document.formData.entries) {
      if (renderedSections.contains(sectionEntry.key)) continue;

      final Map<String, dynamic> sectionData = _sectionData(
        document.formData,
        sectionEntry.key,
      );
      if (sectionData.isEmpty) continue;

      drawSectionTitle(_humanizeKey(sectionEntry.key));
      for (final MapEntry<String, dynamic> fieldEntry in sectionData.entries) {
        final String value = _displayValue(fieldEntry.value, null);
        if (value.isEmpty) continue;

        drawWrappedText(_humanizeKey(fieldEntry.key), labelFont, secondaryBrush);
        drawWrappedText(value, valueFont, textBrush, bottomGap: 8);
      }
    }

    final List<int> bytes = await pdfDocument.save();
    pdfDocument.dispose();
    return bytes;
  }

  Future<Uint8List> _fontBytes(String assetPath) async {
    final ByteData fontData = await rootBundle.load(assetPath);
    return fontData.buffer.asUint8List(
      fontData.offsetInBytes,
      fontData.lengthInBytes,
    );
  }

  Future<String> _savePdfToDevice({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (!Platform.isAndroid) {
      return _savePdfToTemporaryFile(fileName: fileName, bytes: bytes);
    }

    try {
      return await _savePdfWithAndroidChannel(fileName: fileName, bytes: bytes);
    } on PlatformException catch (error) {
      if (error.code == 'permission_denied') {
        final PermissionStatus permissionStatus = await Permission.storage.request();
        if (permissionStatus.isGranted) {
          return _savePdfWithAndroidChannel(fileName: fileName, bytes: bytes);
        }
      }
      return _savePdfToTemporaryFile(fileName: fileName, bytes: bytes);
    } on MissingPluginException {
      return _savePdfToTemporaryFile(fileName: fileName, bytes: bytes);
    }
  }

  Future<String> _savePdfWithAndroidChannel({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final String? savedPath = await _downloadChannel.invokeMethod<String>(
      'savePdfToDownloads',
      <String, dynamic>{
        'fileName': fileName,
        'bytes': bytes,
      },
    );

    if (savedPath == null || savedPath.trim().isEmpty) {
      throw const FileSystemException('Unable to save PDF file.');
    }

    return savedPath;
  }

  Future<String> _savePdfToTemporaryFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final File file = File('${Directory.systemTemp.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Map<String, dynamic> _sectionData(
    Map<String, dynamic> formData,
    String sectionKey,
  ) {
    final dynamic rawSection = formData[sectionKey];
    if (rawSection is Map<String, dynamic>) return rawSection;
    if (rawSection is Map) return Map<String, dynamic>.from(rawSection);
    return <String, dynamic>{};
  }

  String? _findPhotoUrl({
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) {
    for (final CvTemplateSectionModel section in template.schema.sections) {
      final Map<String, dynamic> sectionData = _sectionData(
        document.formData,
        section.key,
      );

      for (final CvTemplateFieldModel field in section.fields) {
        if (!_isPhotoField(field)) continue;

        final String photoUrl = sectionData[field.key]?.toString().trim() ?? '';
        if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
          return photoUrl;
        }
      }
    }

    return null;
  }

  Future<Uint8List?> _loadPhotoBytes(String? photoUrl) async {
    if (photoUrl == null || photoUrl.trim().isEmpty) return null;

    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(photoUrl));
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) return null;

      final BytesBuilder bytesBuilder = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        bytesBuilder.add(chunk);
      }
      return bytesBuilder.takeBytes();
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  String _displayValue(dynamic rawValue, CvTemplateFieldModel? field) {
    if (rawValue == null) return '';

    if (_isPhotoField(field)) {
      final String photoUrl = rawValue.toString().trim();
      return photoUrl.isEmpty ? '' : 'Photo attached';
    }

    if (rawValue is List) {
      return rawValue
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .map((String item) => '• $item')
          .join('\n');
    }

    return rawValue.toString().trim();
  }

  bool _isPhotoField(CvTemplateFieldModel? field) {
    if (field == null) return false;

    final String type = field.type.trim().toLowerCase();
    return type == 'photourl' ||
        type == 'photo_url' ||
        type == 'imageurl' ||
        type == 'photo';
  }

  List<String> _wrapText({
    required String text,
    required PdfFont font,
    required double maxWidth,
  }) {
    final List<String> lines = <String>[];
    final List<String> paragraphs = text.split('\n');

    for (final String paragraph in paragraphs) {
      final String trimmedParagraph = paragraph.trim();
      if (trimmedParagraph.isEmpty) {
        lines.add('');
        continue;
      }

      final List<String> words = trimmedParagraph.split(RegExp(r'\s+'));
      String currentLine = '';

      for (final String word in words) {
        final String proposedLine = currentLine.isEmpty ? word : '$currentLine $word';
        if (font.measureString(proposedLine).width <= maxWidth) {
          currentLine = proposedLine;
          continue;
        }

        if (currentLine.isNotEmpty) lines.add(currentLine);
        currentLine = word;
      }

      if (currentLine.isNotEmpty) lines.add(currentLine);
    }

    return lines.isEmpty ? <String>[''] : lines;
  }

  PdfColor _hexToPdfColor(String hexValue) {
    final String normalizedHex = hexValue.replaceAll('#', '').trim();
    if (normalizedHex.length != 6) return PdfColor(0, 107, 63);

    final int? red = int.tryParse(normalizedHex.substring(0, 2), radix: 16);
    final int? green = int.tryParse(normalizedHex.substring(2, 4), radix: 16);
    final int? blue = int.tryParse(normalizedHex.substring(4, 6), radix: 16);

    return PdfColor(red ?? 0, green ?? 107, blue ?? 63);
  }

  String _safeFileName(String title) {
    final String normalizedTitle = title
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9 _-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final String safeTitle = normalizedTitle.isEmpty ? 'my_cv' : normalizedTitle;
    return '$safeTitle.pdf';
  }

  String _humanizeKey(String key) {
    final String withSpaces = key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (Match match) {
      return '${match.group(1)} ${match.group(2)}';
    });

    return withSpaces
        .split(' ')
        .where((String part) => part.trim().isNotEmpty)
        .map((String part) {
      final String lowered = part.toLowerCase();
      return '${lowered[0].toUpperCase()}${lowered.substring(1)}';
    }).join(' ');
  }
}
