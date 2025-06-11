// lib/features/file_management/presentation/widgets/file_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../bloc/file_management_bloc.dart';
import '../bloc/file_management_event.dart';
import '../bloc/file_management_state.dart';
import 'file_preview_modal.dart';

class FileItem extends StatelessWidget {
  final FileEntity file;
  final ViewMode viewMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;

  const FileItem({
    super.key,
    required this.file,
    this.viewMode = ViewMode.list,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.showCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewMode) {
      case ViewMode.grid:
        return _buildGridItem(context);
      case ViewMode.tiles:
        return _buildTileItem(context);
      case ViewMode.list:
      default:
        return _buildListItem(context);
    }
  }

  Widget _buildListItem(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCheckbox)
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleSelection(context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            _buildFileIcon(context),
          ],
        ),
        title: Text(
          file.displayName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${file.sizeFormatted} • ${_formatDate(file.dateModified)}',
              style: theme.textTheme.bodySmall,
            ),
            if (file.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: file.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.isFavorite)
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 16,
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'preview',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Preview'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: file.isFavorite ? 'unfavorite' : 'favorite',
                  child: ListTile(
                    leading: Icon(file.isFavorite ? Icons.favorite_border : Icons.favorite),
                    title: Text(file.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'rename',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap ?? () => _handleTap(context),
        onLongPress: onLongPress ?? () => _handleLongPress(context),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        onLongPress: onLongPress ?? () => _handleLongPress(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCheckbox)
                Align(
                  alignment: Alignment.topRight,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleSelection(context),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              Expanded(
                flex: 3,
                child: Center(
                  child: _buildFileIcon(context, size: 48),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.displayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file.sizeFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    if (file.isFavorite) ...[
                      const SizedBox(height: 2),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 12,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTileItem(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isSelected ? 4 : 2,
      color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        onLongPress: onLongPress ?? () => _handleLongPress(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (showCheckbox) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleSelection(context),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
              ],
              _buildFileIcon(context, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file.sizeFormatted} • ${_formatDate(file.dateModified)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (file.type == FileType.video && file.duration != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDuration(file.duration!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (file.isFavorite)
                Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context, {double size = 24}) {
    final theme = Theme.of(context);
    IconData iconData;
    Color iconColor;

    switch (file.type) {
      case FileType.image:
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case FileType.video:
        iconData = Icons.video_file;
        iconColor = Colors.red;
        break;
      case FileType.audio:
        iconData = Icons.audio_file;
        iconColor = Colors.purple;
        break;
      case FileType.document:
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case FileType.archive:
        iconData = Icons.archive;
        iconColor = Colors.orange;
        break;
      case FileType.application:
        iconData = Icons.apps;
        iconColor = Colors.indigo;
        break;
      case FileType.text:
        iconData = Icons.text_snippet;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = theme.iconTheme.color ?? Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(size > 30 ? 12 : 8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        size: size,
        color: iconColor,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleTap(BuildContext context) {
    if (showCheckbox) {
      _toggleSelection(context);
    } else {
      // Update access count
      context.read<FileManagementBloc>().add(
        AddTag(path: file.path, tag: 'accessed'),
      );
      
      // Open file preview or external app
      _openFile(context);
    }
  }

  void _handleLongPress(BuildContext context) {
    _toggleSelection(context);
  }

  void _toggleSelection(BuildContext context) {
    context.read<FileManagementBloc>().add(
      ToggleFileSelection(path: file.path),
    );
  }

  void _openFile(BuildContext context) {
    // In a real implementation, you would use packages like:
    // - open_file to open files with system apps
    // - file_preview to show file previews
    
    if (file.canPreview) {
      showDialog(
        context: context,
        builder: (context) => FilePreviewModal(file: file),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot preview ${file.extension} files'),
          action: SnackBarAction(
            label: 'Open with...',
            onPressed: () {
              // Open with system app
            },
          ),
        ),
      );
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    final bloc = context.read<FileManagementBloc>();
    
    switch (action) {
      case 'preview':
        _openFile(context);
        break;
      case 'share':
        // Implement file sharing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality not implemented')),
        );
        break;
      case 'favorite':
        bloc.add(AddToFavorites(path: file.path));
        break;
      case 'unfavorite':
        bloc.add(RemoveFromFavorites(path: file.path));
        break;
      case 'rename':
        _showRenameDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: file.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'File name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<FileManagementBloc>().add(
                  RenameFile(
                    path: file.path,
                    newName: controller.text.trim(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FileManagementBloc>().add(
                DeleteFile(filePath: file.path),
              );
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
