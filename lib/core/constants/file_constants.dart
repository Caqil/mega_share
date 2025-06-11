class FileConstants {
  // File Size Limits
  static const int maxFileSizeBytes = 10 * 1024 * 1024 * 1024; // 10 GB
  static const int maxTotalTransferSizeBytes = 50 * 1024 * 1024 * 1024; // 50 GB
  static const int maxFilesPerTransfer = 1000;

  // Chunk Sizes for Transfer
  static const int defaultChunkSize = 64 * 1024; // 64 KB
  static const int largeFileChunkSize = 1024 * 1024; // 1 MB
  static const int smallFileChunkSize = 32 * 1024; // 32 KB
  static const int bufferSize = 1024 * 1024; // 1 MB

  // File Types
  static const List<String> imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
    '.ico',
  ];

  static const List<String> videoExtensions = [
    '.mp4',
    '.avi',
    '.mkv',
    '.mov',
    '.wmv',
    '.flv',
    '.webm',
    '.m4v',
    '.3gp',
  ];

  static const List<String> audioExtensions = [
    '.mp3',
    '.wav',
    '.aac',
    '.flac',
    '.ogg',
    '.wma',
    '.m4a',
    '.opus',
  ];

  static const List<String> documentExtensions = [
    '.pdf',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.ppt',
    '.pptx',
    '.txt',
    '.rtf',
  ];

  static const List<String> archiveExtensions = [
    '.zip',
    '.rar',
    '.7z',
    '.tar',
    '.gz',
    '.bz2',
    '.xz',
  ];

  static const List<String> codeExtensions = [
    '.dart',
    '.java',
    '.kt',
    '.swift',
    '.js',
    '.ts',
    '.py',
    '.cpp',
    '.c',
    '.h',
  ];

  // MIME Types
  static const Map<String, String> mimeTypes = {
    // Images
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.bmp': 'image/bmp',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',

    // Videos
    '.mp4': 'video/mp4',
    '.avi': 'video/x-msvideo',
    '.mkv': 'video/x-matroska',
    '.mov': 'video/quicktime',
    '.wmv': 'video/x-ms-wmv',
    '.flv': 'video/x-flv',
    '.webm': 'video/webm',

    // Audio
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav',
    '.aac': 'audio/aac',
    '.flac': 'audio/flac',
    '.ogg': 'audio/ogg',
    '.m4a': 'audio/mp4',

    // Documents
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.xls': 'application/vnd.ms-excel',
    '.xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.txt': 'text/plain',

    // Archives
    '.zip': 'application/zip',
    '.rar': 'application/x-rar-compressed',
    '.7z': 'application/x-7z-compressed',
    '.tar': 'application/x-tar',
    '.gz': 'application/gzip',
  };

  // Default Paths
  static const String defaultReceivePath =
      '/storage/emulated/0/Download/ShareIt';
  static const String tempTransferPath =
      '/data/data/com.example.shareit/cache/transfers';
  static const String thumbnailCachePath =
      '/data/data/com.example.shareit/cache/thumbnails';

  // File Validation
  static const List<String> prohibitedExtensions = [
    '.exe',
    '.bat',
    '.cmd',
    '.com',
    '.pif',
    '.scr',
    '.vbs',
    '.js',
  ];

  // Thumbnail Settings
  static const int thumbnailSize = 200;
  static const int thumbnailQuality = 85;
  static const Duration thumbnailCacheTimeout = Duration(days: 7);
}

enum FileCategory { image, video, audio, document, archive, code, app, other }
