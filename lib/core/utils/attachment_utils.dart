import 'dart:io';

import 'package:flutter/material.dart';

class AttachmentUtils {
  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

  static String extensionFromPath(String path) {
    final normalized = _stripUrlSuffix(path);
    final dotIndex = normalized.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == normalized.length - 1) return '';
    return normalized.substring(dotIndex + 1).toLowerCase();
  }

  static String fileNameFromPath(String path) {
    final normalized = _stripUrlSuffix(path).replaceAll('\\', '/');
    final slashIndex = normalized.lastIndexOf('/');
    final name = slashIndex == -1
        ? normalized
        : normalized.substring(slashIndex + 1);

    if (name.isEmpty) return 'Tệp đính kèm';
    return _safeDecode(name);
  }

  static bool isImagePath(String path) {
    return _imageExtensions.contains(extensionFromPath(path));
  }

  static IconData iconForPath(String path) {
    switch (extensionFromPath(path)) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  static String _stripUrlSuffix(String value) {
    return value.split('?').first.split('#').first;
  }

  static String _safeDecode(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (_) {
      return value;
    }
  }
}
