
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import '../bloc/file_management_bloc.dart';
import '../bloc/file_management_event.dart';
import '../bloc/file_management_state.dart';

class FileTypeFilter extends StatelessWidget {
  final bool showAllOption;
  final bool showClearOption;

  const FileTypeFilter({
    super.key,
    this.showAllOption = true,
    this.showClearOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileManagementBloc, FileManagementState>(
      builder: (context, state) {
        return Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Filter by Type',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (showClearOption && state.hasFilter)
                      TextButton(
                        onPressed: () {
                          context.read<FileManagementBloc>().add(
                            const ClearFilter(),
                          );
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (showAllOption)
                      _buildFilterChip(
                        context,
                        'All',
                        Icons.select_all,
                        null,
                        state.currentFilter == null,
                      ),
                    ...FileType.values.map((type) {
                      final isSelected = state.currentFilter?.types?.contains(type) ?? false;
                      return _buildFilterChip(
                        context,
                        _getTypeDisplayName(type),
                        _getTypeIcon(type),
                        type,
                        isSelected,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    FileType? type,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : _getTypeColor(type),
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (type == null) {
            // "All" option
            context.read<FileManagementBloc>().add(
              const ClearFilter(),
            );
          } else {
            // Specific file type
            context.read<FileManagementBloc>().add(
              ApplyFilter(filter: FileFilter(types: [type])),
            );
          }
        },
        backgroundColor: Colors.grey[100],
        selectedColor: _getTypeColor(type),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodySmall?.color,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }

  String _getTypeDisplayName(FileType type) {
    switch (type) {
      case FileType.image:
        return 'Images';
      case FileType.video:
        return 'Videos';
      case FileType.audio:
        return 'Audio';
      case FileType.document:
        return 'Documents';
      case FileType.archive:
        return 'Archives';
      case FileType.application:
        return 'Apps';
      case FileType.text:
        return 'Text';
      case FileType.unknown:
        return 'Other';
    }
  }

  IconData _getTypeIcon(FileType? type) {
    if (type == null) return Icons.select_all;
    
    switch (type) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.video_file;
      case FileType.audio:
        return Icons.audio_file;
      case FileType.document:
        return Icons.description;
      case FileType.archive:
        return Icons.archive;
      case FileType.application:
        return Icons.apps;
      case FileType.text:
        return Icons.text_snippet;
      case FileType.unknown:
        return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(FileType? type) {
    if (type == null) return Colors.grey;
    
    switch (type) {
      case FileType.image:
        return Colors.green;
      case FileType.video:
        return Colors.red;
      case FileType.audio:
        return Colors.purple;
      case FileType.document:
        return Colors.blue;
      case FileType.archive:
        return Colors.orange;
      case FileType.application:
        return Colors.indigo;
      case FileType.text:
        return Colors.grey;
      case FileType.unknown:
        return Colors.grey;
    }
  }
}
