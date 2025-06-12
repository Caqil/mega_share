import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/features/file_management/presentation/bloc/file_management_bloc.dart';
import 'package:mega_share/features/file_management/presentation/widgets/file_item.dart';
import 'package:mega_share/shared/widgets/common/custom_button.dart';

import '../bloc/file_management_event.dart';
import '../bloc/file_management_state.dart';

class FileSelectionPage extends StatefulWidget {
  final String selectionMode;

  const FileSelectionPage({super.key, required this.selectionMode});

  @override
  State<FileSelectionPage> createState() => _FileSelectionPageState();
}

class _FileSelectionPageState extends State<FileSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectionMode == 'send'
              ? 'Select Files to Send'
              : 'Select Destination',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<FileManagementBloc, FileManagementState>(
            builder: (context, state) {
              if (state.selectedFiles.isEmpty) return const SizedBox();

              return TextButton(
                onPressed: _onSelectAll,
                child: Text('${state.selectedFiles.length} selected'),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FileManagementBloc, FileManagementState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text('No files found', style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Try selecting a different folder',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // File Type Filter
              _buildFileTypeFilter(),

              // File List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FileItem(
                        file: file,
                        showCheckbox: true,
                        isSelected: state.selectedFiles.contains(file.path),
                        onTap: () => _toggleFileSelection(file.path),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Action Bar
              _buildBottomActionBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileTypeFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', null),
          _buildFilterChip('Images', 'image'),
          _buildFilterChip('Videos', 'video'),
          _buildFilterChip('Documents', 'document'),
          _buildFilterChip('Audio', 'audio'),
          _buildFilterChip('Apps', 'app'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? type) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false, // TODO: Implement filter state
        onSelected: (selected) {
          // TODO: Implement filter logic
        },
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return BlocBuilder<FileManagementBloc, FileManagementState>(
      builder: (context, state) {
        if (state.selectedFiles.isEmpty) return const SizedBox();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${state.selectedFiles.length} files selected',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              CustomButton(
                text: widget.selectionMode == 'send' ? 'Send Files' : 'Select',
                onPressed: _onConfirmSelection,
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleFileSelection(String filePath) {
    context.read<FileManagementBloc>().add(ToggleFileSelection(path: filePath));
  }

  void _onSelectAll() {
    // TODO: Implement select all logic
  }

  void _onConfirmSelection() {
    final bloc = context.read<FileManagementBloc>();
    final selectedFiles = bloc.state.selectedFiles;

    if (selectedFiles.isEmpty) return;

    // Navigate to next step based on selection mode
    if (widget.selectionMode == 'send') {
      // Navigate to device discovery for sending
      context.go(
        '/device-discovery?mode=send',
        extra: {'selectedFiles': selectedFiles.toList()},
      );
    } else {
      // Handle other selection modes
      context.pop(selectedFiles.toList());
    }
  }
}
