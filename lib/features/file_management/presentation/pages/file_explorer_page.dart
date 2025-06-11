// lib/features/file_management/presentation/pages/file_explorer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../../domain/repositories/file_management_repository.dart';
import '../bloc/file_management_bloc.dart';
import '../bloc/file_management_event.dart';
import '../bloc/file_management_state.dart';
import '../widgets/file_item.dart';
import '../widgets/folder_item.dart';
import '../widgets/storage_indicator.dart';
import '../widgets/file_type_filter.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({super.key});

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load initial data
    final bloc = context.read<FileManagementBloc>();
    bloc.add(const CheckPermissions());
    bloc.add(const LoadStorageInfo());
    bloc.add(LoadFiles(refresh: true));
    bloc.add(LoadFolders());
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (!state.hasReadPermission) {
            return _buildPermissionScreen(context);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBrowserTab(context, state),
              _buildRecentTab(context, state),
              _buildFavoritesTab(context, state),
              _buildCategoriesTab(context, state),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(context),
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
                    SearchFiles(query: query),
                  );
                }
              },
            )
          : BlocBuilder<FileManagementBloc, FileManagementState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('File Explorer'),
                    if (state.currentPath != '/storage/emulated/0')
                      Text(
                        _getDisplayPath(state.currentPath),
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                  ],
                );
              },
            ),
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
          IconButton(
            onPressed: () => _showSortMenu(context),
            icon: const Icon(Icons.sort),
          ),
          BlocBuilder<FileManagementBloc, FileManagementState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'view_${state.viewMode == ViewMode.list ? 'grid' : 'list'}',
                    child: ListTile(
                      leading: Icon(state.viewMode == ViewMode.list ? Icons.grid_view : Icons.list),
                      title: Text(state.viewMode == ViewMode.list ? 'Grid View' : 'List View'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'hidden',
                    child: ListTile(
                      leading: Icon(state.showHidden ? Icons.visibility_off : Icons.visibility),
                      title: Text(state.showHidden ? 'Hide Hidden Files' : 'Show Hidden Files'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'new_folder',
                    child: ListTile(
                      leading: Icon(Icons.create_new_folder),
                      title: Text('New Folder'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(icon: Icon(Icons.folder), text: 'Browser'),
          Tab(icon: Icon(Icons.history), text: 'Recent'),
          Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
          Tab(icon: Icon(Icons.category), text: 'Categories'),
        ],
      ),
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
            Icon(
              Icons.folder_off,
              size: 80,
              color: theme.primaryColor,
            ),
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
              'To browse and manage files, please grant storage permissions.',
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowserTab(BuildContext context, FileManagementState state) {
    return Column(
      children: [
        // Navigation bar
        if (state.canNavigateBack || state.currentPath != '/storage/emulated/0')
          Container(
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
                      ? () => context.read<FileManagementBloc>().add(const NavigateBack())
                      : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: () => context.read<FileManagementBloc>().add(const NavigateToRoot()),
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
          ),

        // Storage indicator
        StorageIndicator(storageInfo: state.storageInfo),

        // File type filter
        if (!_isSearchActive) const FileTypeFilter(),

        // Selection bar
        if (state.hasSelection)
          Container(
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
                  '${state.selectedCount} selected',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.read<FileManagementBloc>().add(
                    const ClearSelection(),
                  ),
                  child: const Text('Clear'),
                ),
                IconButton(
                  onPressed: () => _showBulkActions(context, state.selectedFiles.toList()),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

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
  }

  Widget _buildRecentTab(BuildContext context, FileManagementState state) {
    return Column(
      children: [
        const FileTypeFilter(),
        Expanded(
          child: BlocBuilder<FileManagementBloc, FileManagementState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FileManagementBloc>().add(const LoadRecentFiles());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return FileItem(
                      file: file,
                      viewMode: state.viewMode,
                      isSelected: state.selectedFiles.contains(file.path),
                      showCheckbox: state.hasSelection,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(BuildContext context, FileManagementState state) {
    return Column(
      children: [
        const FileTypeFilter(),
        Expanded(
          child: BlocBuilder<FileManagementBloc, FileManagementState>(
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
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add files to favorites to see them here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FileManagementBloc>().add(const LoadFavoriteFiles());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return FileItem(
                      file: file,
                      viewMode: state.viewMode,
                      isSelected: state.selectedFiles.contains(file.path),
                      showCheckbox: state.hasSelection,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab(BuildContext context, FileManagementState state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCategoryCard(
          context,
          'Images',
          Icons.image,
          Colors.green,
          FileType.image,
        ),
        _buildCategoryCard(
          context,
          'Videos',
          Icons.video_file,
          Colors.red,
          FileType.video,
        ),
        _buildCategoryCard(
          context,
          'Audio',
          Icons.audio_file,
          Colors.purple,
          FileType.audio,
        ),
        _buildCategoryCard(
          context,
          'Documents',
          Icons.description,
          Colors.blue,
          FileType.document,
        ),
        _buildCategoryCard(
          context,
          'Archives',
          Icons.archive,
          Colors.orange,
          FileType.archive,
        ),
        _buildCategoryCard(
          context,
          'Applications',
          Icons.apps,
          Colors.indigo,
          FileType.application,
        ),
        _buildCategoryCard(
          context,
          'Large Files',
          Icons.storage,
          Colors.grey,
          null,
          onTap: () {
            context.read<FileManagementBloc>().add(const LoadLargeFiles());
            _tabController.animateTo(1); // Switch to Recent tab to show results
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    FileType? type, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: BlocBuilder<FileManagementBloc, FileManagementState>(
          builder: (context, state) {
            final count = state.storageInfo?.fileTypeDistribution[type] ?? 0;
            return Text(
              type != null ? '$count files' : 'View large files',
              style: theme.textTheme.bodySmall,
            );
          },
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap ?? () {
          if (type != null) {
            context.read<FileManagementBloc>().add(
              LoadFilesByType(type: type),
            );
            _tabController.animateTo(1); // Switch to Recent tab to show results
          }
        },
      ),
    );
  }

  Widget _buildFileList(BuildContext context, FileManagementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final allItems = [...state.folders, ...state.files];
    
    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Empty folder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'No files or folders in this location',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FileManagementBloc>().add(
          LoadFiles(refresh: true),
        );
        context.read<FileManagementBloc>().add(LoadFolders());
      },
      child: state.viewMode == ViewMode.grid
          ? GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                if (index < state.folders.length) {
                  return FolderItem(
                    folder: state.folders[index],
                    showDetails: false,
                  );
                } else {
                  final fileIndex = index - state.folders.length;
                  final file = state.files[fileIndex];
                  return FileItem(
                    file: file,
                    viewMode: ViewMode.grid,
                    isSelected: state.selectedFiles.contains(file.path),
                    showCheckbox: state.hasSelection,
                  );
                }
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                if (index < state.folders.length) {
                  return FolderItem(folder: state.folders[index]);
                } else {
                  final fileIndex = index - state.folders.length;
                  final file = state.files[fileIndex];
                  return FileItem(
                    file: file,
                    viewMode: state.viewMode,
                    isSelected: state.selectedFiles.contains(file.path),
                    showCheckbox: state.hasSelection,
                  );
                }
              },
            ),
    );
  }

  Widget _buildSearchResults(BuildContext context, FileManagementState state) {
    if (state.searchResults.isEmpty && state.searchQuery?.isNotEmpty == true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final file = state.searchResults[index];
        return FileItem(
          file: file,
          viewMode: state.viewMode,
          isSelected: state.selectedFiles.contains(file.path),
          showCheckbox: state.hasSelection,
        );
      },
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<FileManagementBloc, FileManagementState>(
      builder: (context, state) {
        if (!state.hasWritePermission) return const SizedBox.shrink();
        
        return FloatingActionButton(
          onPressed: () => _showNewFolderDialog(context),
          child: const Icon(Icons.create_new_folder),
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

  void _showSortMenu(BuildContext context) {
    final state = context.read<FileManagementBloc>().state;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...SortBy.values.map((sortBy) {
              return ListTile(
                leading: Radio<SortBy>(
                  value: sortBy,
                  groupValue: state.sortBy,
                  onChanged: (value) {
                    context.read<FileManagementBloc>().add(
                      ChangeSortOrder(
                        sortBy: value!,
                        sortOrder: state.sortOrder,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(_getSortDisplayName(sortBy)),
                onTap: () {
                  context.read<FileManagementBloc>().add(
                    ChangeSortOrder(
                      sortBy: sortBy,
                      sortOrder: state.sortOrder,
                    ),
                  );
                  Navigator.of(context).pop();
                },
              );
            }),
            const Divider(),
            ListTile(
              leading: Icon(
                state.sortOrder == SortOrder.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
              title: Text(
                state.sortOrder == SortOrder.ascending
                    ? 'Ascending'
                    : 'Descending',
              ),
              onTap: () {
                context.read<FileManagementBloc>().add(
                  ChangeSortOrder(
                    sortBy: state.sortBy,
                    sortOrder: state.sortOrder == SortOrder.ascending
                        ? SortOrder.descending
                        : SortOrder.ascending,
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getSortDisplayName(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.name:
        return 'Name';
      case SortBy.size:
        return 'Size';
      case SortBy.dateModified:
        return 'Date Modified';
      case SortBy.dateCreated:
        return 'Date Created';
      case SortBy.type:
        return 'Type';
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    final bloc = context.read<FileManagementBloc>();
    
    switch (action) {
      case 'view_grid':
        bloc.add(const ChangeViewMode(viewMode: ViewMode.grid));
        break;
      case 'view_list':
        bloc.add(const ChangeViewMode(viewMode: ViewMode.list));
        break;
      case 'hidden':
        bloc.add(const ToggleShowHidden());
        break;
      case 'new_folder':
        _showNewFolderDialog(context);
        break;
      case 'refresh':
        bloc.add(LoadFiles(refresh: true));
        bloc.add(LoadFolders());
        bloc.add(const RefreshStorageInfo());
        break;
    }
  }

  void _showNewFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
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
                final state = context.read<FileManagementBloc>().state;
                context.read<FileManagementBloc>().add(
                  CreateFolder(
                    parentPath: state.currentPath,
                    name: controller.text.trim(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showBulkActions(BuildContext context, List<String> selectedPaths) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions for ${selectedPaths.length} items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement bulk share
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement bulk copy
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_cut),
              title: const Text('Move'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement bulk move
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _showBulkDeleteDialog(context, selectedPaths);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context, List<String> selectedPaths) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Files'),
        content: Text('Are you sure you want to delete ${selectedPaths.length} items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FileManagementBloc>().add(
                DeleteFile(filePaths: selectedPaths),
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

