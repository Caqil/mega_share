import 'package:get_it/get_it.dart';
import '../features/device_discovery/data/datasources/nearby_devices_datasource.dart';
import '../features/device_discovery/data/datasources/nearby_devices_datasource_impl.dart';
import '../features/device_discovery/data/repositories/device_discovery_repository_impl.dart';
import '../features/device_discovery/domain/repositories/device_discovery_repository.dart';
import '../features/device_discovery/domain/usecases/start_advertising_usecase.dart';
import '../features/device_discovery/domain/usecases/start_discovery_usecase.dart';
import '../features/device_discovery/domain/usecases/stop_advertising_usecase.dart';
import '../features/device_discovery/domain/usecases/stop_discovery_usecase.dart';
import '../features/device_discovery/presentation/bloc/device_discovery_bloc.dart';
import 'register_modules.dart';

/// Device discovery feature module
class DeviceDiscoveryModule extends DIModule {
  static Future<void> register(GetIt sl) async {
    // Data Sources
    sl.registerLazySingleton<NearbyDevicesDataSource>(
      () => NearbyDevicesDataSourceImpl(),
    );

    // Repositories
    sl.registerLazySingleton<DeviceDiscoveryRepository>(
      () => DeviceDiscoveryRepositoryImpl(dataSource: sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => StartDiscoveryUseCase(sl()));

    sl.registerLazySingleton(() => StopDiscoveryUseCase(sl()));

    sl.registerLazySingleton(() => StartAdvertisingUseCase(sl()));

    sl.registerLazySingleton(() => StopAdvertisingUseCase(sl()));

    // BLoCs
    sl.registerFactory(
      () => DeviceDiscoveryBloc(
        startDiscoveryUseCase: sl(),
        stopDiscoveryUseCase: sl(),
        startAdvertisingUseCase: sl(),
        stopAdvertisingUseCase: sl(),
        repository: sl(),
      ),
    );

    print('✅ DeviceDiscoveryModule registered');
  }
}
