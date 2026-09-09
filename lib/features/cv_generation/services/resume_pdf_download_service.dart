import 'dart:io';
import 'dart:typed_data';

import 'package:media_store_plus/media_store_plus.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class ResumePdfDownloadService {
  static const String _androidFolderName = 'ItalirPothe';
  static Future<void>? _androidInitialization;

  final MediaStore _mediaStore = MediaStore();

  Future<String> savePdfToDevice({
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    if (pdfBytes.isEmpty) {
      throw StateError('cvb_pdf_empty'.tr);
    }

    final String normalizedFileName = _normalizeFileName(fileName);

    if (Platform.isAndroid) {
      return _saveAndroid(bytes: pdfBytes, fileName: normalizedFileName);
    }

    if (Platform.isIOS) {
      return _saveIos(bytes: pdfBytes, fileName: normalizedFileName);
    }

    throw UnsupportedError('cvb_download_mobile_only'.tr);
  }

  Future<String> _saveAndroid({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await _ensureAndroidInitialized();

    final Directory temporaryDirectory = await getTemporaryDirectory();
    final File temporaryFile = File('${temporaryDirectory.path}/$fileName');

    try {
      await temporaryFile.writeAsBytes(bytes, flush: true);

      final SaveInfo? saveInfo = await _mediaStore.saveFile(
        tempFilePath: temporaryFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );

      if (saveInfo == null) {
        throw StateError('cvb_save_downloads_failed'.tr);
      }

      final String savedName = saveInfo.name.trim().isEmpty
          ? fileName
          : saveInfo.name.trim();

      return 'Downloads/$_androidFolderName/$savedName';
    } finally {
      if (await temporaryFile.exists()) {
        try {
          await temporaryFile.delete();
        } catch (_) {
          // Temporary-file cleanup failure is not user-facing.
        }
      }
    }
  }

  Future<String> _saveIos({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    if (!await file.exists()) {
      throw StateError('cvb_save_iphone_failed'.tr);
    }

    return 'Files/On My iPhone/ItalirPothe/$fileName';
  }

  Future<void> _ensureAndroidInitialized() {
    return _androidInitialization ??= _initializeAndroid();
  }

  static Future<void> _initializeAndroid() async {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = _androidFolderName;
  }

  String _normalizeFileName(String value) {
    String fileName = value.trim().isEmpty ? 'my-cv.pdf' : value.trim();
    fileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');
    fileName = fileName.replaceAll(RegExp(r'\s+'), '-');
    while (fileName.contains('--')) {
      fileName = fileName.replaceAll('--', '-');
    }
    if (!fileName.toLowerCase().endsWith('.pdf')) {
      fileName = '$fileName.pdf';
    }
    return fileName;
  }
}
