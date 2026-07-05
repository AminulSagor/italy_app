import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/cv_builder_models.dart';
import 'cv_visual_pdf_renderer.dart';

class CvPdfDownloadService {
  CvPdfDownloadService({CvVisualPdfRenderer? visualPdfRenderer})
    : _visualPdfRenderer = visualPdfRenderer ?? CvVisualPdfRenderer();

  static const MethodChannel _downloadChannel = MethodChannel(
    'italir_pothe/downloads',
  );

  final CvVisualPdfRenderer _visualPdfRenderer;

  Future<Uint8List> buildCreatedCvPdfBytes({
    required CvDocumentModel document,
    required CvTemplateModel template,
  }) async {
    final List<int> pdfBytes = await _visualPdfRenderer.build(
      document: document,
      template: template,
    );

    return Uint8List.fromList(pdfBytes);
  }

  Future<String> downloadCreatedCv({
    required CvDocumentModel document,
    required CvTemplateModel template,
    Uint8List? pdfBytes,
  }) async {
    final Uint8List bytes =
        pdfBytes ??
        await buildCreatedCvPdfBytes(document: document, template: template);

    return _savePdfToDevice(
      fileName: _safeFileName(document.title),
      bytes: bytes,
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
        final PermissionStatus permissionStatus = await Permission.storage
            .request();
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
      <String, dynamic>{'fileName': fileName, 'bytes': bytes},
    );

    if (savedPath == null || savedPath.trim().isEmpty) {
      throw FileSystemException('unable_to_save_pdf_file'.tr);
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

  String _safeFileName(String title) {
    final String normalizedTitle = title
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9 _-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final String safeTitle = normalizedTitle.isEmpty
        ? 'my_cv'
        : normalizedTitle;
    return '$safeTitle.pdf';
  }
}
