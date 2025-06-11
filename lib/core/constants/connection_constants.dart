class ConnectionConstants {
  // Service ID for Nearby Connections
  static const String serviceId = 'com.example.shareit.transfer';

  // Strategy for Nearby Connections
  static const String strategy =
      'P2P_CLUSTER'; // P2P_CLUSTER, P2P_STAR, P2P_POINT_TO_POINT

  // Connection Settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration disconnectionTimeout = Duration(seconds: 10);
  static const Duration keepAliveInterval = Duration(seconds: 15);
  static const int maxConnectionAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Discovery Settings
  static const Duration discoveryDuration = Duration(minutes: 5);
  static const Duration advertisingDuration = Duration(minutes: 10);
  static const String discoveryName = 'ShareIt Device';

  // Transfer Settings
  static const int maxConcurrentTransfers = 4;
  static const Duration transferTimeout = Duration(minutes: 30);
  static const Duration progressUpdateInterval = Duration(milliseconds: 500);
  static const int maxRetransmissionAttempts = 5;

  // WiFi Hotspot Settings
  static const String hotspotSSID = 'ShareIt_Hotspot';
  static const String hotspotPassword = 'shareit123';
  static const int hotspotPort = 8888;
  static const String hotspotIP = '192.168.43.1';

  // QR Code Settings
  static const int qrCodeSize = 300;
  static const String qrCodePrefix = 'SHAREIT://';
  static const Duration qrCodeTimeout = Duration(minutes: 5);

  // Security Settings
  static const int authTokenLength = 32;
  static const Duration authTokenExpiry = Duration(minutes: 10);
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const int nonceLength = 12;

  // Network Settings
  static const int socketBufferSize = 65536; // 64 KB
  static const Duration socketTimeout = Duration(seconds: 30);
  static const int maxPacketSize = 1024 * 1024; // 1 MB
  static const int headerSize = 64; // bytes

  // Protocol Messages
  static const String msgHandshake = 'HANDSHAKE';
  static const String msgHandshakeAck = 'HANDSHAKE_ACK';
  static const String msgFileInfo = 'FILE_INFO';
  static const String msgFileChunk = 'FILE_CHUNK';
  static const String msgTransferComplete = 'TRANSFER_COMPLETE';
  static const String msgTransferCancel = 'TRANSFER_CANCEL';
  static const String msgTransferPause = 'TRANSFER_PAUSE';
  static const String msgTransferResume = 'TRANSFER_RESUME';
  static const String msgAck = 'ACK';
  static const String msgError = 'ERROR';

  // Error Codes
  static const int errorConnectionFailed = 1001;
  static const int errorTransferFailed = 1002;
  static const int errorFileNotFound = 1003;
  static const int errorPermissionDenied = 1004;
  static const int errorInsufficientStorage = 1005;
  static const int errorUnsupportedFile = 1006;
  static const int errorNetworkUnavailable = 1007;
  static const int errorDeviceNotFound = 1008;
  static const int errorAuthenticationFailed = 1009;
  static const int errorTimeout = 1010;
}

// Connection States
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  authenticating,
  authenticated,
  transferring,
  error,
}

// Transfer States
enum TransferState {
  pending,
  preparing,
  transferring,
  paused,
  completed,
  failed,
  cancelled,
}

// Device Types
enum DeviceType { android, ios, windows, macos, linux, unknown }

// Connection Types
enum ConnectionType {
  nearbyConnections,
  wifiDirect,
  wifiHotspot,
  bluetooth,
  qrCode,
  unknown,
}
