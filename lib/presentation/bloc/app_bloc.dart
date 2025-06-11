
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class AppInitialized extends AppEvent {
  const AppInitialized();
}

class AppPermissionsRequested extends AppEvent {
  const AppPermissionsRequested();
}

class AppSettingsChanged extends AppEvent {
  const AppSettingsChanged();
}

// States
abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {
  const AppInitial();
}

class AppLoading extends AppState {
  const AppLoading();
}

class AppReady extends AppState {
  final bool hasPermissions;
  final bool isFirstLaunch;
  
  const AppReady({
    required this.hasPermissions,
    required this.isFirstLaunch,
  });

  @override
  List<Object?> get props => [hasPermissions, isFirstLaunch];
}

class AppError extends AppState {
  final String message;
  
  const AppError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class AppBloc extends Bloc<AppEvent, AppState> {
  final SharedPreferences _sharedPreferences;
  
  AppBloc({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(const AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AppInitialized>(_onAppInitialized);
    on<AppPermissionsRequested>(_onAppPermissionsRequested);
    on<AppSettingsChanged>(_onAppSettingsChanged);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(const AppLoading());
    
    try {
      // Check if first launch
      final isFirstLaunch = _sharedPreferences.getBool('first_launch') ?? true;
      
      // TODO: Check permissions status
      final hasPermissions = true; // Placeholder
      
      await Future.delayed(const Duration(seconds: 2)); // Splash delay
      
      emit(AppReady(
        hasPermissions: hasPermissions,
        isFirstLaunch: isFirstLaunch,
      ));
      
      if (isFirstLaunch) {
        await _sharedPreferences.setBool('first_launch', false);
      }
    } catch (e) {
      emit(AppError(message: e.toString()));
    }
  }

  Future<void> _onAppInitialized(AppInitialized event, Emitter<AppState> emit) async {
    // Handle post-initialization tasks
  }

  Future<void> _onAppPermissionsRequested(AppPermissionsRequested event, Emitter<AppState> emit) async {
    // Handle permission requests
  }

  Future<void> _onAppSettingsChanged(AppSettingsChanged event, Emitter<AppState> emit) async {
    // Handle settings changes
  }
}
