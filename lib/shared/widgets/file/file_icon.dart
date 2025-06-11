// lib/shared/widgets/file/file_icon.dart
import 'package:flutter/material.dart';
import '../../../core/constants/file_constants.dart';
import '../../../core/constants/file_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/file_extensions.dart';

/// File icon widget that displays appropriate icon based on file type
class FileIcon extends StatelessWidget {
  final String? filePath;
  final String? fileName;
  final String? extension;
  final FileCategory? category;
  final double size;
  final Color? color;
  final bool showBackground;
  final Color? backgroundColor;

  const FileIcon({
    super.key,
    this.filePath,
    this.fileName,
    this.extension,
    this.category,
    this.size = 24,
    this.color,
    this.showBackground = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final fileCategory = _getFileCategory();
    final iconData = _getIconForCategory(fileCategory);
    final iconColor = color ?? _getColorForCategory(context, fileCategory);

    Widget iconWidget = Icon(iconData, size: size, color: iconColor);

    if (showBackground) {
      iconWidget = Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          color: backgroundColor ?? iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: iconWidget),
      );
    }

    return iconWidget;
  }

  FileCategory _getFileCategory() {
    // Use provided category first
    if (category != null) return category!;

    // Determine from extension
    String? fileExtension = extension;
    if (fileExtension == null && fileName != null) {
      fileExtension = fileName!.split('.').last.toLowerCase();
      if (!fileExtension.startsWith('.')) {
        fileExtension = '.$fileExtension';
      }
    }
    if (fileExtension == null && filePath != null) {
      fileExtension = filePath!.split('.').last.toLowerCase();
      if (!fileExtension.startsWith('.')) {
        fileExtension = '.$fileExtension';
      }
    }

    if (fileExtension == null) return FileCategory.other;

    // Use file utils to determine category
    if (FileConstants.imageExtensions.contains(fileExtension)) {
      return FileCategory.image;
    } else if (FileConstants.videoExtensions.contains(fileExtension)) {
      return FileCategory.video;
    } else if (FileConstants.audioExtensions.contains(fileExtension)) {
      return FileCategory.audio;
    } else if (FileConstants.documentExtensions.contains(fileExtension)) {
      return FileCategory.document;
    } else if (FileConstants.archiveExtensions.contains(fileExtension)) {
      return FileCategory.archive;
    } else if (FileConstants.codeExtensions.contains(fileExtension)) {
      return FileCategory.code;
    } else if (fileExtension == '.apk' || fileExtension == '.ipa') {
      return FileCategory.app;
    }

    return FileCategory.other;
  }

  IconData _getIconForCategory(FileCategory category) {
    switch (category) {
      case FileCategory.image:
        return Icons.image_outlined;
      case FileCategory.video:
        return Icons.video_file_outlined;
      case FileCategory.audio:
        return Icons.audio_file_outlined;
      case FileCategory.document:
        return Icons.description_outlined;
      case FileCategory.archive:
        return Icons.archive_outlined;
      case FileCategory.code:
        return Icons.code_outlined;
      case FileCategory.app:
        return Icons.android_outlined;
      case FileCategory.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getColorForCategory(BuildContext context, FileCategory category) {
    final colorScheme = context.colorScheme;

    switch (category) {
      case FileCategory.image:
        return Colors.green;
      case FileCategory.video:
        return Colors.red;
      case FileCategory.audio:
        return Colors.orange;
      case FileCategory.document:
        return Colors.blue;
      case FileCategory.archive:
        return Colors.purple;
      case FileCategory.code:
        return Colors.teal;
      case FileCategory.app:
        return Colors.indigo;
      case FileCategory.other:
        return colorScheme.onSurfaceVariant;
    }
  }
}

/// Specialized file icon for specific file types
class SpecializedFileIcon extends StatelessWidget {
  final String extension;
  final double size;
  final Color? color;

  const SpecializedFileIcon({
    super.key,
    required this.extension,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getSpecializedIcon();
    final iconColor = color ?? _getSpecializedColor();

    return Icon(iconData, size: size, color: iconColor);
  }

  IconData _getSpecializedIcon() {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf_outlined;
      case '.doc':
      case '.docx':
        return Icons.description_outlined;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart_outlined;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow_outlined;
      case '.zip':
      case '.rar':
      case '.7z':
        return Icons.archive_outlined;
      case '.txt':
        return Icons.text_snippet_outlined;
      case '.apk':
        return Icons.android_outlined;
      case '.ipa':
        return Icons.phone_iphone_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getSpecializedColor() {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Colors.red;
      case '.doc':
      case '.docx':
        return Colors.blue;
      case '.xls':
      case '.xlsx':
        return Colors.green;
      case '.ppt':
      case '.pptx':
        return Colors.orange;
      case '.zip':
      case '.rar':
      case '.7z':
        return Colors.purple;
      case '.txt':
        return Colors.grey;
      case '.apk':
        return Colors.green;
      case '.ipa':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
