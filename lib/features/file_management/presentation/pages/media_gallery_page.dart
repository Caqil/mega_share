import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/file_entity.dart';
import '../bloc/file_management_bloc.dart';
import '../bloc/file_management_event.dart';
import '../bloc/file_management_state.dart';
import '../widgets/file_item.dart';
import '../widgets/file_type_filter.dart';

class MediaGalleryPage extends StatefulWidget {
  final FileType mediaType;

  const MediaGalleryPage({super.key, this.mediaType = FileType.image});

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load initial data
    final bloc = context.read<FileManagementBloc>();
    bloc.add(const CheckPermissions());
    bloc.add(LoadFilesByType(type: widget.mediaType));
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
              _buildAllMediaTab(context, state),
              _buildFavoritesTab(context, state),
              _buildRecentTab(context, state),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(context) {
    final title = _getMediaTypeTitle(widget.mediaType);

    return AppBar(
      title: _isSearchActive
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search media...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  context.read<FileManagementBloc>().add(
                    SearchFiles(query: query, types: [widget.mediaType]),
                  );
                }
              },
            )
          : Text('$title Gallery'),
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
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'slideshow',
                child: ListTile(
                  leading: Icon(Icons.slideshow),
                  title: Text('Slideshow'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(icon: Icon(Icons.grid_view), text: 'All'),
          Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
          Tab(icon: Icon(Icons.history), text: 'Recent'),
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
              _getMediaTypeIcon(widget.mediaType),
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
              'To view media files, please grant storage permissions.',
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

  Widget _buildAllMediaTab(BuildContext context, FileManagementState state) {
    return Column(
      children: [
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.read<FileManagementBloc>().add(
                    const ClearSelection(),
                  ),
                  child: const Text('Clear'),
                ),
                IconButton(
                  onPressed: () =>
                      _showBulkActions(context, state.selectedFiles.toList()),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),

        // Media grid
        Expanded(
          child: _isSearchActive && state.isSearching
              ? const Center(child: CircularProgressIndicator())
              : _isSearchActive
              ? _buildSearchResults(context, state)
              : _buildMediaGrid(context, state),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(BuildContext context, FileManagementState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FileManagementBloc>().add(
          LoadFavoriteFiles(types: [widget.mediaType]),
        );
      },
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
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add ${_getMediaTypeTitle(widget.mediaType).toLowerCase()} to favorites to see them here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return _buildMediaGrid(context, state);
        },
      ),
    );
  }

  Widget _buildRecentTab(BuildContext context, FileManagementState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FileManagementBloc>().add(
          LoadRecentFiles(types: [widget.mediaType]),
        );
      },
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
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No recent files',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recently accessed ${_getMediaTypeTitle(widget.mediaType).toLowerCase()} will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return _buildMediaGrid(context, state);
        },
      ),
    );
  }

  Widget _buildMediaGrid(BuildContext context, FileManagementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final mediaFiles = state.files
        .where((file) => file.type == widget.mediaType)
        .toList();

    if (mediaFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getMediaTypeIcon(widget.mediaType),
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_getMediaTypeTitle(widget.mediaType).toLowerCase()} found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'No ${_getMediaTypeTitle(widget.mediaType).toLowerCase()} files in this location',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.mediaType == FileType.video ? 2 : 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: widget.mediaType == FileType.audio ? 1.2 : 1.0,
      ),
      itemCount: mediaFiles.length,
      itemBuilder: (context, index) {
        final file = mediaFiles[index];
        return FileItem(
          file: file,
          viewMode: ViewMode.grid,
          isSelected: state.selectedFiles.contains(file.path),
          showCheckbox: state.hasSelection,
          onTap: () => _handleMediaTap(context, file, mediaFiles, index),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, FileManagementState state) {
    final mediaResults = state.searchResults
        .where((file) => file.type == widget.mediaType)
        .toList();

    if (mediaResults.isEmpty && state.searchQuery?.isNotEmpty == true) {
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

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.mediaType == FileType.video ? 2 : 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: widget.mediaType == FileType.audio ? 1.2 : 1.0,
      ),
      itemCount: mediaResults.length,
      itemBuilder: (context, index) {
        final file = mediaResults[index];
        return FileItem(
          file: file,
          viewMode: ViewMode.grid,
          isSelected: state.selectedFiles.contains(file.path),
          showCheckbox: state.hasSelection,
          onTap: () => _handleMediaTap(context, file, mediaResults, index),
        );
      },
    );
  }

  String _getMediaTypeTitle(FileType type) {
    switch (type) {
      case FileType.image:
        return 'Images';
      case FileType.video:
        return 'Videos';
      case FileType.audio:
        return 'Audio';
      default:
        return 'Media';
    }
  }

  IconData _getMediaTypeIcon(FileType type) {
    switch (type) {
      case FileType.image:
        return Icons.image;
      case FileType.video:
        return Icons.video_library;
      case FileType.audio:
        return Icons.library_music;
      default:
        return Icons.perm_media;
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    final bloc = context.read<FileManagementBloc>();

    switch (action) {
      case 'refresh':
        bloc.add(LoadFilesByType(type: widget.mediaType));
        break;
      case 'slideshow':
        if (widget.mediaType == FileType.image) {
          // Implement slideshow
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slideshow functionality not implemented'),
            ),
          );
        }
        break;
    }
  }

  void _handleMediaTap(
    BuildContext context,
    FileEntity file,
    List<FileEntity> allFiles,
    int index,
  ) {
    final state = context.read<FileManagementBloc>().state;

    if (state.hasSelection) {
      // Toggle selection if in selection mode
      context.read<FileManagementBloc>().add(
        ToggleFileSelection(path: file.path),
      );
    } else {
      // Open media viewer/player
      _openMediaViewer(context, file, allFiles, index);
    }
  }

  void _openMediaViewer(
    BuildContext context,
    FileEntity file,
    List<FileEntity> allFiles,
    int index,
  ) {
    // In a real implementation, you would open a full-screen media viewer
    // For images: use packages like photo_view
    // For videos: use packages like video_player
    // For audio: use packages like just_audio

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Media Viewer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(file.displayName),
              const SizedBox(height: 8),
              Text('${file.sizeFormatted} • ${file.extension.toUpperCase()}'),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getMediaTypeIcon(widget.mediaType),
                  size: 64,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Media preview implementation needed',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Share functionality
                    },
                    child: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
              leading: const Icon(Icons.favorite),
              title: const Text('Add to Favorites'),
              onTap: () {
                Navigator.of(context).pop();
                for (final path in selectedPaths) {
                  context.read<FileManagementBloc>().add(
                    AddToFavorites(path: path),
                  );
                }
              },
            ),
            if (widget.mediaType == FileType.image) ...[
              ListTile(
                leading: const Icon(Icons.slideshow),
                title: const Text('Slideshow'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Implement slideshow
                },
              ),
            ],
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
        title: Text('Delete ${_getMediaTypeTitle(widget.mediaType)}'),
        content: Text(
          'Are you sure you want to delete ${selectedPaths.length} items?',
        ),
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
