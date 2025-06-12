import 'package:get_it/get_it.dart';
import 'package:mega_share/core/utils/logger_impl.dart';

// Core imports
import '../core/network/network_info_impl.dart';
import '../core/services/logger_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/storage_service.dart';
import '../core/storage/secure_storage_impl.dart';
import '../core/utils/device_info_helper.dart';
import '../core/utils/device_info_helper_impl.dart';

// Connection feature imports
import '../../features/connection/data/datasources/nearby_connection_datasource.dart';
import '../../features/connection/data/datasources/nearby_connection_datasource_impl.dart';
import '../../features/connection/data/repositories/connection_repository_impl.dart';
import '../../features/connection/domain/repositories/connection_repository.dart';
import '../../features/connection/domain/usecases/accept_connection_usecase.dart';
import '../../features/connection/domain/usecases/connect_to_device_usecase.dart';
import '../../features/connection/domain/usecases/disconnect_from_device_usecase.dart';
import '../../features/connection/domain/usecases/get_connection_info_usecase.dart';
import '../../features/connection/domain/usecases/reject_connection_usecase.dart';
import '../../features/connection/domain/usecases/start_discovery_usecase.dart';
import '../../features/connection/domain/usecases/stop_discovery_usecase.dart';
import '../../features/connection/domain/usecases/generate_qr_code_usecase.dart';
import '../../features/connection/domain/usecases/connect_from_qr_code_usecase.dart';
import '../../features/connection/domain/usecases/manage_wifi_hotspot_usecase.dart';
import '../../features/connection/presentation/bloc/connection_bloc.dart';

// File management feature imports
import '../../features/file_management/data/datasources/file_system_datasource.dart';
import '../../features/file_management/data/datasources/file_system_datasource_impl.dart';
import '../../features/file_management/data/repositories/file_management_repository_impl.dart';
import '../../features/file_management/domain/repositories/file_management_repository.dart';
import '../../features/file_management/domain/usecases/get_storage_info_usecase.dart';
import '../../features/file_management/domain/usecases/get_files_usecase.dart';
import '../../features/file_management/domain/usecases/get_folders_usecase.dart';
import '../../features/file_management/domain/usecases/create_folder_usecase.dart';
import '../../features/file_management/domain/usecases/delete_file_usecase.dart';
import '../../features/file_management/domain/usecases/manage_file_usecase.dart';
import '../../features/file_management/domain/usecases/request_permissions_usecase.dart';
import '../../features/file_management/presentation/bloc/file_management_bloc.dart';

// // Transfer feature imports
// import '../../features/transfer/data/datasources/transfer_datasource.dart';
// import '../../features/transfer/data/datasources/transfer_datasource_impl.dart';
// import '../../features/transfer/data/repositories/transfer_repository_impl.dart';
// import '../../features/transfer/domain/repositories/transfer_repository.dart';
// import '../../features/transfer/domain/usecases/start_transfer_usecase.dart';
// import '../../features/transfer/domain/usecases/pause_transfer_usecase.dart';
// import '../../features/transfer/domain/usecases/resume_transfer_usecase.dart';
// import '../../features/transfer/domain/usecases/cancel_transfer_usecase.dart';
// import '../../features/transfer/domain/usecases/get_transfer_history_usecase.dart';
// import '../../features/transfer/presentation/bloc/transfer_bloc.dart';

// Home feature imports
import '../../features/home/presentation/bloc/home_bloc.dart';

// App-level imports
import '../../presentation/bloc/app_bloc.dart';
import '../../presentation/bloc/theme_bloc.dart';

/// Base class for all dependency injection modules
abstract class DIModule {
  static Future<void> register(GetIt sl) async {
    throw UnimplementedError('register() must be implemented by subclasses');
  }
}

/// Core module - registers shared utilities and services
class CoreModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // Network
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

    // Secure Storage
    sl.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());

    // Logger
    sl.registerLazySingleton<AppLogger>(() => AppLoggerImpl());

    // Device Info Helper
    sl.registerLazySingleton<DeviceInfoHelper>(() => DeviceInfoHelperImpl());
  }
}

/// Connection feature module
class ConnectionModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // Data Sources
    sl.registerLazySingleton<NearbyConnectionDataSource>(
      () => NearbyConnectionDataSourceImpl(),
    );

    // Repositories
    sl.registerLazySingleton<ConnectionRepository>(
      () => ConnectionRepositoryImpl(dataSource: sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetConnectionInfoUseCase(repository: sl()));

    sl.registerLazySingleton(() => ConnectToDeviceUseCase(repository: sl()));

    sl.registerLazySingleton(() => AcceptConnectionUseCase(repository: sl()));

    sl.registerLazySingleton(() => RejectConnectionUseCase(repository: sl()));

    sl.registerLazySingleton(
      () => DisconnectFromDeviceUseCase(repository: sl()),
    );

    sl.registerLazySingleton(() => StartDiscoveryUseCase(repository: sl()));

    sl.registerLazySingleton(() => StopDiscoveryUseCase(repository: sl()));

    sl.registerLazySingleton(() => GenerateQRCodeUseCase(repository: sl()));

    sl.registerLazySingleton(() => ConnectFromQRCodeUseCase(repository: sl()));

    sl.registerLazySingleton(() => ManageWiFiHotspotUseCase(repository: sl()));

    // BLoCs
    sl.registerFactory(
      () => ConnectionBloc(
        getConnectionInfoUseCase: sl(),
        connectToDeviceUseCase: sl(),
        acceptConnectionUseCase: sl(),
        rejectConnectionUseCase: sl(),
        disconnectFromDeviceUseCase: sl(),
        startDiscoveryUseCase: sl(),
        stopDiscoveryUseCase: sl(),
        generateQRCodeUseCase: sl(),
        connectFromQRCodeUseCase: sl(),
        manageWiFiHotspotUseCase: sl(),
        repository: sl(),
      ),
    );
  }
}

/// File management feature module
class FileManagementModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // Data Sources
    sl.registerLazySingleton<FileSystemDataSource>(
      () => FileSystemDataSourceImpl(),
    );

    // Repositories
    sl.registerLazySingleton<FileManagementRepository>(
      () => FileManagementRepositoryImpl(dataSource: sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetStorageInfoUseCase(repository: sl()));

    sl.registerLazySingleton(() => GetFilesUseCase(repository: sl()));

    sl.registerLazySingleton(() => GetFoldersUseCase(repository: sl()));

    sl.registerLazySingleton(() => CreateFolderUseCase(repository: sl()));

    sl.registerLazySingleton(() => DeleteFileUseCase(repository: sl()));

    sl.registerLazySingleton(() => ManageFileUseCase(repository: sl()));

    sl.registerLazySingleton(() => RequestPermissionsUseCase(repository: sl()));

    // BLoCs
    sl.registerFactory(
      () => FileManagementBloc(
        getStorageInfoUseCase: sl(),
        getFilesUseCase: sl(),
        getFoldersUseCase: sl(),
        createFolderUseCase: sl(),
        deleteFileUseCase: sl(),
        manageFileUseCase: sl(),
        requestPermissionsUseCase: sl(),
      ),
    );
  }
}

/// Transfer feature module
class TransferModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // Data Sources
    sl.registerLazySingleton<TransferDataSource>(
      () => TransferDataSourceImpl(
        connectionRepository: sl(),
        fileRepository: sl(),
        logger: sl(),
      ),
    );

    // Repositories
    sl.registerLazySingleton<TransferRepository>(
      () => TransferRepositoryImpl(dataSource: sl(), logger: sl()),
    );

    // Use Cases
    sl.registerLazySingleton(
      () => StartTransferUseCase(repository: sl(), logger: sl()),
    );

    sl.registerLazySingleton(
      () => PauseTransferUseCase(repository: sl(), logger: sl()),
    );

    sl.registerLazySingleton(
      () => ResumeTransferUseCase(repository: sl(), logger: sl()),
    );

    sl.registerLazySingleton(
      () => CancelTransferUseCase(repository: sl(), logger: sl()),
    );

    sl.registerLazySingleton(() => GetTransferHistoryUseCase(repository: sl()));

    // BLoCs
    sl.registerFactory(
      () => TransferBloc(
        startTransferUseCase: sl(),
        pauseTransferUseCase: sl(),
        resumeTransferUseCase: sl(),
        cancelTransferUseCase: sl(),
        getTransferHistoryUseCase: sl(),
      ),
    );
  }
}

/// Home feature module
class HomeModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // BLoCs - Don't inject singleton services, let HomeBloc use its defaults
    sl.registerFactory(
      () => HomeBloc(
        // Don't inject the services - let HomeBloc use singleton instances
        // storageService: StorageService.instance,
        // permissionService: PermissionService.instance,
        // logger: LoggerService.instance,
      ),
    );
  }
}

/// App-level module
class AppModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // BLoCs
    sl.registerFactory(() => AppBloc(sharedPreferences: sl()));

    sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));

    sl.registerFactory(
      () => SettingsBloc(
        sharedPreferences: sl(),
        secureStorage: sl(),
        logger: sl(),
      ),
    );
  }
}

// lib/core/network/network_info.dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<String?> get connectionType;
  Future<String?> get wifiName;
  Future<String?> get wifiBSSID;
  Stream<bool> get onConnectivityChanged;
}

// lib/core/storage/secure_storage.dart
abstract class SecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
  Future<Map<String, String>> readAll();
}

// Add missing imports for placeholder classes
// These would be implemented in their respective feature modules

// Placeholder transfer feature classes (to be implemented)
abstract class TransferDataSource {}

class TransferDataSourceImpl implements TransferDataSource {
  final dynamic connectionRepository;
  final dynamic fileRepository;
  final dynamic logger;

  TransferDataSourceImpl({
    required this.connectionRepository,
    required this.fileRepository,
    required this.logger,
  });
}

abstract class TransferRepository {}

class TransferRepositoryImpl implements TransferRepository {
  final TransferDataSource dataSource;
  final dynamic logger;

  TransferRepositoryImpl({required this.dataSource, required this.logger});
}

// Placeholder use cases
class StartTransferUseCase {
  final TransferRepository repository;
  final dynamic logger;

  StartTransferUseCase({required this.repository, required this.logger});
}

class PauseTransferUseCase {
  final TransferRepository repository;
  final dynamic logger;

  PauseTransferUseCase({required this.repository, required this.logger});
}

class ResumeTransferUseCase {
  final TransferRepository repository;
  final dynamic logger;

  ResumeTransferUseCase({required this.repository, required this.logger});
}

class CancelTransferUseCase {
  final TransferRepository repository;
  final dynamic logger;

  CancelTransferUseCase({required this.repository, required this.logger});
}

class GetTransferHistoryUseCase {
  final TransferRepository repository;

  GetTransferHistoryUseCase({required this.repository});
}

// Placeholder BLoCs
class TransferBloc {
  TransferBloc({
    required StartTransferUseCase startTransferUseCase,
    required PauseTransferUseCase pauseTransferUseCase,
    required ResumeTransferUseCase resumeTransferUseCase,
    required CancelTransferUseCase cancelTransferUseCase,
    required GetTransferHistoryUseCase getTransferHistoryUseCase,
  });
}

class SettingsBloc {
  SettingsBloc({
    required dynamic sharedPreferences,
    required dynamic secureStorage,
    required dynamic logger,
  });
}
