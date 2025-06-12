// lib/injection/injection.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/connection/data/datasources/nearby_connection_datasource.dart';
import '../features/file_management/data/datasources/file_system_datasource.dart';

// Import singleton services
import '../core/services/storage_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/notification_service.dart';

import 'device_discovery_module.dart';
import 'register_modules.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Initialize external dependencies first
  await _initExternalDependencies();

  // Initialize singleton services BEFORE registering modules
  await _initializeSingletonServices();

  // Register all modules
  await _registerModules();

  // Initialize services that require async setup
  await _initializeServices();
}

/// Initialize external dependencies (databases, shared preferences, etc.)
Future<void> _initExternalDependencies() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

/// Initialize singleton services (these use their own singleton pattern)
Future<void> _initializeSingletonServices() async {
  try {
    // Initialize StorageService
    await StorageService.instance.initialize();
    print('✅ StorageService initialized');

    // Initialize PermissionService
    await PermissionService.instance.initialize();
    print('✅ PermissionService initialized');

    // Initialize LoggerService
    await LoggerService.instance.initialize(
      minLogLevel: LogLevel.debug,
      writeToFile: false,
      writeToConsole: true,
    );
    print('✅ LoggerService initialized');

    // Initialize NotificationService
    await NotificationService.instance.initialize();
    print('✅ NotificationService initialized');
  } catch (e) {
    print('❌ Error initializing singleton services: $e');
    rethrow;
  }
}

/// Register all feature modules
Future<void> _registerModules() async {
  try {
    // Core modules
    await CoreModule.register(sl);
    print('✅ CoreModule registered');

    // Feature modules
    await ConnectionModule.register(sl);
    print('✅ ConnectionModule registered');

    await FileManagementModule.register(sl);
    print('✅ FileManagementModule registered');

    await TransferModule.register(sl);
    print('✅ TransferModule registered');

    // ADD HOME MODULE HERE
    await DeviceDiscoveryModule.register(sl);
    print('✅ DeviceDiscoveryModule registered');
    await HomeModule.register(sl);
    await AppModule.register(sl);
    print('✅ AppModule registered');
  } catch (e) {
    print('❌ Error registering modules: $e');
    rethrow;
  }
}

/// Initialize services that require async initialization
Future<void> _initializeServices() async {
  try {
    // Initialize file system data source
    final fileSystemDataSource = sl.get<FileSystemDataSource>();
    await fileSystemDataSource.initialize();
    print('✅ FileSystemDataSource initialized');

    // Initialize connection data source
    final connectionDataSource = sl.get<NearbyConnectionDataSource>();
    await connectionDataSource.initialize();
    print('✅ NearbyConnectionDataSource initialized');
  } catch (e) {
    print('❌ Error initializing services: $e');
    rethrow;
  }
}

/// Clean up all dependencies
Future<void> disposeDependencies() async {
  try {
    // Dispose services
    final fileSystemDataSource = sl.get<FileSystemDataSource>();
    await fileSystemDataSource.dispose();

    final connectionDataSource = sl.get<NearbyConnectionDataSource>();
    await connectionDataSource.dispose();

    // Dispose singleton services
    PermissionService.instance.dispose();
    // Note: StorageService and LoggerService don't have dispose methods in your current implementation

    // Reset GetIt
    await sl.reset();
    print('✅ Dependencies disposed');
  } catch (e) {
    print('❌ Error disposing dependencies: $e');
    rethrow;
  }
}
