import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeSettings extends ThemeEvent {
  const LoadThemeSettings();
}

class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeMode({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

// States
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({required this.themeMode, required this.isDarkMode});

  @override
  List<Object?> get props => [themeMode, isDarkMode];

  ThemeState copyWith({ThemeMode? themeMode, bool? isDarkMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _sharedPreferences;

  ThemeBloc({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences,
      super(const ThemeState(themeMode: ThemeMode.system, isDarkMode: false)) {
    on<LoadThemeSettings>(_onLoadThemeSettings);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadThemeSettings(
    LoadThemeSettings event,
    Emitter<ThemeState> emit,
  ) async {
    final themeModeIndex = _sharedPreferences.getInt('theme_mode') ?? 0;
    final themeMode = ThemeMode.values[themeModeIndex];
    final isDarkMode = themeMode == ThemeMode.dark;

    emit(state.copyWith(themeMode: themeMode, isDarkMode: isDarkMode));
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<ThemeState> emit,
  ) async {
    await _sharedPreferences.setInt('theme_mode', event.themeMode.index);

    emit(
      state.copyWith(
        themeMode: event.themeMode,
        isDarkMode: event.themeMode == ThemeMode.dark,
      ),
    );
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final newThemeMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    add(ChangeThemeMode(themeMode: newThemeMode));
  }
}
