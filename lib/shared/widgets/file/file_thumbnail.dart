import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/file_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import 'file_icon.dart';

/// File thumbnail widget with fallback to icon
class FileThumbnail extends StatelessWidget {
  final String filePath;
  final double width;
  final double height;
  final BoxFit fit;
  final bool showIcon;
  final double iconSize;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const FileThumbnail({
    super.key,
    required this.filePath,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.showIcon = true,
    this.iconSize = 24,
    this.borderRadius,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final extension = filePath.split('.').last.toLowerCase();
    final isImage = FileConstants.imageExtensions.contains('.$extension');

    if (isImage) {
      return _buildImageThumbnail(context);
    } else {
      return _buildIconThumbnail(context);
    }
  }

  Widget _buildImageThumbnail(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: context.colorScheme.surfaceContainerHighest,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Image.file(
          File(filePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildIconThumbnail(context);
          },
        ),
      ),
    );
  }

  Widget _buildIconThumbnail(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        color: context.colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: FileIcon(filePath: filePath, size: iconSize),
      ),
    );
  }
}

/// Grid thumbnail for file gallery view
class GridFileThumbnail extends StatelessWidget {
  final String filePath;
  final String fileName;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showCheckbox;
  final Function(bool?)? onSelectionChanged;

  const GridFileThumbnail({
    super.key,
    required this.filePath,
    required this.fileName,
    this.onTap,
    this.isSelected = false,
    this.showCheckbox = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FileThumbnail(
                      filePath: filePath,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                    ),
                  ),
                  if (showCheckbox)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: onSelectionChanged,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                fileName,
                style: context.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
