// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mega_share/app/theme/app_theme.dart';

import '../features/connection/presentation/bloc/connection_bloc.dart';
import '../features/file_management/presentation/bloc/file_management_bloc.dart';
import '../features/home/presentation/bloc/home_bloc.dart'; // ADD THIS IMPORT
import '../presentation/bloc/app_bloc.dart';
import '../presentation/bloc/theme_bloc.dart';
import 'router/app_router.dart';

class ShareItApp extends StatelessWidget {
  const ShareItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // App-level BLoCs
        BlocProvider<AppBloc>(
          create: (context) =>
              GetIt.instance<AppBloc>()..add(const AppStarted()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) =>
              GetIt.instance<ThemeBloc>()..add(const LoadThemeSettings()),
        ),

        // Feature BLoCs
        BlocProvider<ConnectionBloc>(
          create: (context) => GetIt.instance<ConnectionBloc>(),
        ),
        BlocProvider<FileManagementBloc>(
          create: (context) => GetIt.instance<FileManagementBloc>(),
        ),
        // ADD HOME BLOC PROVIDER
        BlocProvider<HomeBloc>(create: (context) => GetIt.instance<HomeBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'ShareIt - File Transfer',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,

            // Routing
            routerConfig: AppRouter.router,

            // Localization (if needed)
            // locale: context.watch<AppBloc>().state.locale,
            // localizationsDelegates: AppLocalizations.localizationsDelegates,
            // supportedLocales: AppLocalizations.supportedLocales,

            // Builder for additional wrappers
            builder: (context, child) {
              return MediaQuery(
                // Ensure text scaling doesn't break UI
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(
                    context,
                  ).textScaleFactor.clamp(0.8, 1.3),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
