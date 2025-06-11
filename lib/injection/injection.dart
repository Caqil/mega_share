import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/connection/data/datasources/nearby_connection_datasource.dart';
import '../features/file_management/data/datasources/file_system_datasource.dart';
import 'register_modules.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Initialize external dependencies first
  await _initExternalDependencies();

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

/// Register all feature modules
Future<void> _registerModules() async {
  // Core modules
  await CoreModule.register(sl);

  // Feature modules
  await ConnectionModule.register(sl);
  await FileManagementModule.register(sl);
  await TransferModule.register(sl);
  await AppModule.register(sl);
}

/// Initialize services that require async initialization
Future<void> _initializeServices() async {
  // Initialize file system data source
  final fileSystemDataSource = sl.get<FileSystemDataSource>();
  await fileSystemDataSource.initialize();

  // Initialize connection data source
  final connectionDataSource = sl.get<NearbyConnectionDataSource>();
  await connectionDataSource.initialize();
}

/// Clean up all dependencies
Future<void> disposeDependencies() async {
  // Dispose services
  final fileSystemDataSource = sl.get<FileSystemDataSource>();
  await fileSystemDataSource.dispose();

  final connectionDataSource = sl.get<NearbyConnectionDataSource>();
  await connectionDataSource.dispose();

  // Reset GetIt
  await sl.reset();
}
