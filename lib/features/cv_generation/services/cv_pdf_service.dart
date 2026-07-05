import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CvPdfService {
  CvPdfService({
    Dio? dio,
  }) : _dio = dio ?? Dio();

  static const String _androidFolderName =
      'ItalirPothe';

  static Future<void>? _androidInitialization;

  final Dio _dio;
  final MediaStore _mediaStore = MediaStore();

  /// Creates an A4 PDF from the generated CV image and
  /// saves it directly to the device.
  ///
  /// Android:
  /// Downloads/ItalirPothe/<fileName>
  ///
  /// iOS:
  /// Files -> On My iPhone -> ItalirPothe/<fileName>
  Future<String> createAndSaveA4Pdf({
    required String imageUrl,
    required String fileName,
  }) async {
    final String normalizedUrl =
    imageUrl.trim();

    if (normalizedUrl.isEmpty) {
      throw ArgumentError(
        'The generated CV image URL is missing.',
      );
    }

    final String normalizedFileName =
    _normalizeFileName(fileName);

    final Uint8List imageBytes =
    await _downloadImage(normalizedUrl).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw TimeoutException(
          'Downloading the generated CV image took too long.',
        );
      },
    );

    if (imageBytes.isEmpty) {
      throw StateError(
        'The generated CV image is empty.',
      );
    }

    final Uint8List pdfBytes =
    await _createA4PdfBytes(
      imageBytes,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException(
          'Creating the A4 PDF took too long.',
        );
      },
    );

    if (pdfBytes.isEmpty) {
      throw StateError(
        'The generated PDF is empty.',
      );
    }

    return savePdfToDevice(
      pdfBytes: pdfBytes,
      fileName: normalizedFileName,
    );
  }

  /// Creates the PDF bytes without saving them.
  Future<Uint8List> createA4Pdf({
    required String imageUrl,
  }) async {
    final String normalizedUrl =
    imageUrl.trim();

    if (normalizedUrl.isEmpty) {
      throw ArgumentError(
        'The generated CV image URL is missing.',
      );
    }

    final Uint8List imageBytes =
    await _downloadImage(normalizedUrl).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw TimeoutException(
          'Downloading the generated CV image took too long.',
        );
      },
    );

    return _createA4PdfBytes(
      imageBytes,
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException(
          'Creating the A4 PDF took too long.',
        );
      },
    );
  }

  /// Saves existing PDF bytes directly to the device.
  Future<String> savePdfToDevice({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    if (pdfBytes.isEmpty) {
      throw StateError(
        'The generated PDF is empty.',
      );
    }

    final String normalizedFileName =
    _normalizeFileName(fileName);

    if (Platform.isAndroid) {
      return _savePdfToAndroidDownloads(
        pdfBytes: pdfBytes,
        fileName: normalizedFileName,
      );
    }

    if (Platform.isIOS) {
      return _savePdfToIosDocuments(
        pdfBytes: pdfBytes,
        fileName: normalizedFileName,
      );
    }

    throw UnsupportedError(
      'Direct PDF download is supported only on Android and iOS.',
    );
  }

  Future<Uint8List> _createA4PdfBytes(
      Uint8List imageBytes,
      ) async {
    if (imageBytes.isEmpty) {
      throw StateError(
        'The generated CV image is empty.',
      );
    }

    final pw.Document document =
    pw.Document();

    final pw.MemoryImage cvImage =
    pw.MemoryImage(imageBytes);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            width: PdfPageFormat.a4.width,
            height: PdfPageFormat.a4.height,
            color: PdfColors.white,
            alignment: pw.Alignment.center,
            child: pw.Image(
              cvImage,
              fit: pw.BoxFit.contain,
            ),
          );
        },
      ),
    );

    return document.save();
  }

  Future<String> _savePdfToAndroidDownloads({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    await _ensureAndroidMediaStoreInitialized();

    final Directory temporaryDirectory =
    await getTemporaryDirectory();

    final String temporaryPath =
        '${temporaryDirectory.path}/$fileName';

    final File temporaryFile =
    File(temporaryPath);

    try {
      await temporaryFile.writeAsBytes(
        pdfBytes,
        flush: true,
      );

      final SaveInfo? saveInfo =
      await _mediaStore.saveFile(
        tempFilePath: temporaryFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (saveInfo == null) {
        throw StateError(
          'The PDF could not be saved to the Downloads folder.',
        );
      }

      final String savedName =
      saveInfo.name.trim().isEmpty
          ? fileName
          : saveInfo.name;

      return 'Downloads/$_androidFolderName/$savedName';
    } finally {
      // media_store_plus normally deletes its temporary
      // file after saving, but this also handles failures.
      if (await temporaryFile.exists()) {
        try {
          await temporaryFile.delete();
        } catch (_) {
          // Ignore temporary-file cleanup errors.
        }
      }
    }
  }

  Future<String> _savePdfToIosDocuments({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    final Directory documentsDirectory =
    await getApplicationDocumentsDirectory();

    final File pdfFile = File(
      '${documentsDirectory.path}/$fileName',
    );

    await pdfFile.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    if (!await pdfFile.exists()) {
      throw StateError(
        'The PDF could not be saved on this iPhone.',
      );
    }

    return 'Files/On My iPhone/ItalirPothe/$fileName';
  }

  Future<void>
  _ensureAndroidMediaStoreInitialized() {
    return _androidInitialization ??=
        _initializeAndroidMediaStore();
  }

  static Future<void>
  _initializeAndroidMediaStore() async {
    await MediaStore.ensureInitialized();

    MediaStore.appFolder =
        _androidFolderName;
  }

  Future<Uint8List> _downloadImage(
      String imageUrl,
      ) async {
    final Response<List<int>> response =
    await _dio.get<List<int>>(
      imageUrl,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout:
        const Duration(seconds: 45),
        sendTimeout:
        const Duration(seconds: 20),
        validateStatus: (int? status) {
          return status != null &&
              status >= 200 &&
              status < 300;
        },
      ),
    );

    final List<int>? bytes =
        response.data;

    if (bytes == null || bytes.isEmpty) {
      throw StateError(
        'The generated CV image could not be downloaded.',
      );
    }

    return Uint8List.fromList(bytes);
  }

  String _normalizeFileName(
      String fileName,
      ) {
    String normalized =
    fileName.trim();

    if (normalized.isEmpty) {
      normalized = 'generated-cv.pdf';
    }

    normalized = normalized.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '-',
    );

    normalized = normalized.replaceAll(
      RegExp(r'\s+'),
      '-',
    );

    while (normalized.contains('--')) {
      normalized =
          normalized.replaceAll('--', '-');
    }

    if (!normalized
        .toLowerCase()
        .endsWith('.pdf')) {
      normalized = '$normalized.pdf';
    }

    return normalized;
  }
}