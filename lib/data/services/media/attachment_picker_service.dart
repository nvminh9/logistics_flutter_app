import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentPickerService {
  static const MethodChannel _channel = MethodChannel(
    'nalogistics_app/attachments',
  );

  Future<File?> pickAttachment() async {
    try {
      final path = await _channel.invokeMethod<String>('pickAttachment');
      if (path == null || path.isEmpty) return null;
      return File(path);
    } on MissingPluginException {
      throw PlatformException(
        code: 'MISSING_NATIVE_PICKER',
        message: 'Cần cài lại app để kích hoạt chức năng chọn tệp.',
      );
    }
  }

  Future<String?> downloadAttachment({
    required String url,
    required String fileName,
  }) async {
    try {
      await _channel.invokeMethod<int>('downloadAttachment', {
        'url': url,
        'fileName': fileName,
      });
      return null;
    } on MissingPluginException {
      return _downloadWithDio(url: url, fileName: fileName);
    }
  }

  Future<String> _downloadWithDio({
    required String url,
    required String fileName,
  }) async {
    final directory =
        await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final safeName = _sanitizeFileName(
      fileName.isEmpty ? 'attachment' : fileName,
    );
    final file = File('${directory.path}/$safeName');

    await Dio().download(url, file.path);
    return file.path;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
