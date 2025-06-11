
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/folder_entity.dart';
import '../bloc/file_management_bloc.dart';
import '../bloc/file_management_event.dart';

class FolderItem extends StatelessWidget {
  final FolderEntity folder;
  final VoidCallback? onTap;
  final bool showDetails;

  const FolderItem({
    super.key,
    required this.folder,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            folder.hasSubfolders ? Icons.folder : Icons.folder_open,
            color: Colors.amber[700],
            size: 24,
          ),
        ),
        title: Text(
          folder.displayName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: showDetails ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${folder.totalItems} items • ${folder.sizeFormatted}',
              style: theme.textTheme.bodySmall,
            ),
            if (folder.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: folder.tags.take(3).map((tag) {
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
        ) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (folder.isFavorite)
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
                  value: 'open',
                  child: ListTile(
                    leading: Icon(Icons.folder_open),
                    title: Text('Open'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: folder.isFavorite ? 'unfavorite' : 'favorite',
                  child: ListTile(
                    leading: Icon(folder.isFavorite ? Icons.favorite_border : Icons.favorite),
                    title: Text(folder.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
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
      ),
    );
  }

  void _handleTap(BuildContext context) {
    context.read<FileManagementBloc>().add(
      NavigateToPath(path: folder.path),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    final bloc = context.read<FileManagementBloc>();
    
    switch (action) {
      case 'open':
        _handleTap(context);
        break;
      case 'favorite':
        bloc.add(AddToFavorites(path: folder.path));
        break;
      case 'unfavorite':
        bloc.add(RemoveFromFavorites(path: folder.path));
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
    final controller = TextEditingController(text: folder.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Folder name',
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
                  RenameFolder(
                    path: folder.path,
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
        title: const Text('Delete Folder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${folder.name}"?'),
            if (folder.totalItems > 0) ...[
              const SizedBox(height: 8),
              Text(
                'This folder contains ${folder.totalItems} items.',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FileManagementBloc>().add(
                DeleteFolder(
                  path: folder.path,
                  recursive: folder.totalItems > 0,
                ),
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
