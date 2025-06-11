import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import '../bloc/file_management_bloc.dart';
import '../bloc/file_management_event.dart';
import '../bloc/file_management_state.dart';
import '../widgets/file_item.dart';
import '../widgets/folder_item.dart';
import '../widgets/file_type_filter.dart';

class FileSelectorPage extends StatefulWidget {
  final List<FileType>? allowedTypes;
  final bool multiSelect;
  final String title;
  final int? maxSelection;

  const FileSelectorPage({
    super.key,
    this.allowedTypes,
    this.multiSelect = false,
    this.title = 'Select Files',
    this.maxSelection,
  });

  @override
  State<FileSelectorPage> createState() => _FileSelectorPageState();
}

class _FileSelectorPageState extends State<FileSelectorPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();

    // Load initial data
    final bloc = context.read<FileManagementBloc>();
    bloc.add(const CheckPermissions());
    bloc.add(LoadFiles(refresh: true));
    bloc.add(LoadFolders());

    // Apply initial filter if specified
    if (widget.allowedTypes != null) {
      bloc.add(ApplyFilter(filter: FileFilter(types: widget.allowedTypes)));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocConsumer<FileManagementBloc, FileManagementState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (!state.hasReadPermission) {
            return _buildPermissionScreen(context);
          }

          return Column(
            children: [
              // Navigation bar
              if (state.canNavigateBack ||
                  state.currentPath != '/storage/emulated/0')
                _buildNavigationBar(context, state),

              // File type filter
              if (widget.allowedTypes == null && !_isSearchActive)
                const FileTypeFilter(),

              // Selection info
              if (state.hasSelection) _buildSelectionBar(context, state),

              // File list
              Expanded(
                child: _isSearchActive && state.isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _isSearchActive
                    ? _buildSearchResults(context, state)
                    : _buildFileList(context, state),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: _isSearchActive
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search files...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  context.read<FileManagementBloc>().add(
                    SearchFiles(query: query, types: widget.allowedTypes),
                  );
                }
              },
            )
          : Text(widget.title),
      actions: [
        if (_isSearchActive) ...[
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchActive = false;
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.close),
          ),
        ] else ...[
          IconButton(
            onPressed: () {
              setState(() {
                _isSearchActive = true;
              });
            },
            icon: const Icon(Icons.search),
          ),
          if (widget.multiSelect)
            BlocBuilder<FileManagementBloc, FileManagementState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.hasSelection
                      ? () => _returnSelectedFiles(context, state)
                      : null,
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }

  Widget _buildPermissionScreen(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 80, color: theme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Storage Permission Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To select files, please grant storage permissions.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<FileManagementBloc>().add(
                  const RequestPermissions(),
                );
              },
              icon: const Icon(Icons.security),
              label: const Text('Grant Permissions'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context, FileManagementState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: state.canNavigateBack
                ? () => context.read<FileManagementBloc>().add(
                    const NavigateBack(),
                  )
                : null,
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () =>
                context.read<FileManagementBloc>().add(const NavigateToRoot()),
            icon: const Icon(Icons.home),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getDisplayPath(state.currentPath),
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context, FileManagementState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.multiSelect
                ? '${state.selectedCount} selected'
                : '1 selected',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.maxSelection != null) ...[
            Text(
              ' (max ${widget.maxSelection})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: () =>
                context.read<FileManagementBloc>().add(const ClearSelection()),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList(BuildContext context, FileManagementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredFiles = widget.allowedTypes != null
        ? state.files
              .where((file) => widget.allowedTypes!.contains(file.type))
              .toList()
        : state.files;

    final allItems = [...state.folders, ...filteredFiles];

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              widget.allowedTypes != null
                  ? 'No matching files'
                  : 'Empty folder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.allowedTypes != null
                  ? 'No files of the allowed types found'
                  : 'No files or folders in this location',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FileManagementBloc>().add(LoadFiles(refresh: true));
        context.read<FileManagementBloc>().add(LoadFolders());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          if (index < state.folders.length) {
            return FolderItem(folder: state.folders[index]);
          } else {
            final fileIndex = index - state.folders.length;
            final file = filteredFiles[fileIndex];
            final isSelected = state.selectedFiles.contains(file.path);

            return FileItem(
              file: file,
              viewMode: ViewMode.list,
              isSelected: isSelected,
              showCheckbox: widget.multiSelect,
              onTap: () => _handleFileSelection(context, file, isSelected),
            );
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, FileManagementState state) {
    final filteredResults = widget.allowedTypes != null
        ? state.searchResults
              .where((file) => widget.allowedTypes!.contains(file.type))
              .toList()
        : state.searchResults;

    if (filteredResults.isEmpty && state.searchQuery?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final file = filteredResults[index];
        final isSelected = state.selectedFiles.contains(file.path);

        return FileItem(
          file: file,
          viewMode: ViewMode.list,
          isSelected: isSelected,
          showCheckbox: widget.multiSelect,
          onTap: () => _handleFileSelection(context, file, isSelected),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocBuilder<FileManagementBloc, FileManagementState>(
      builder: (context, state) {
        if (!widget.multiSelect && !state.hasSelection) {
          return const SizedBox.shrink();
        }

        return BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.multiSelect) ...[
                  Text(
                    '${state.selectedCount} selected',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: state.hasSelection
                        ? () => _returnSelectedFiles(context, state)
                        : null,
                    child: const Text('Select'),
                  ),
                ] else if (state.hasSelection) ...[
                  Expanded(
                    child: Text(
                      'Selected: ${state.selectedFiles.first.split('/').last}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _returnSelectedFiles(context, state),
                    child: const Text('Select'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDisplayPath(String path) {
    if (path == '/storage/emulated/0') return 'Internal Storage';
    if (path.startsWith('/storage/emulated/0/')) {
      return path.substring('/storage/emulated/0/'.length);
    }
    return path;
  }

  void _handleFileSelection(
    BuildContext context,
    FileEntity file,
    bool isCurrentlySelected,
  ) {
    final bloc = context.read<FileManagementBloc>();
    final state = bloc.state;

    if (widget.multiSelect) {
      // Check max selection limit
      if (!isCurrentlySelected &&
          widget.maxSelection != null &&
          state.selectedCount >= widget.maxSelection!) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maximum ${widget.maxSelection} files can be selected',
            ),
          ),
        );
        return;
      }

      bloc.add(ToggleFileSelection(path: file.path));
    } else {
      // Single select - clear previous selection and select this file
      bloc.add(const ClearSelection());
      bloc.add(SelectFile(path: file.path));
    }
  }

  void _returnSelectedFiles(BuildContext context, FileManagementState state) {
    final selectedFiles = state.files
        .where((file) => state.selectedFiles.contains(file.path))
        .toList();

    if (selectedFiles.isNotEmpty) {
      Navigator.of(context).pop(selectedFiles);
    }
  }
}
